/*
-- (c) Copyright 2018 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
*/
#include <assert.h>

#include <math.h>
#include <unistd.h>
#include <algorithm>
#include <array>
#include <chrono>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <memory>
#include <string>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/opencv.hpp>

// Header files for DNNDK API
#include <dnndk/dnndk.h>

// DPU input & output Node name for DenseBox
#define NODE_INPUT "L0"
#define NODE_CONV "pixel_conv"
#define NODE_OUTPUT "bb_output"

#define IMAGE_SCALE (0.02)
#define CONFIDENCE_THRESHOLD (0.65)
#define IOU_THRESHOLD (0.3)

using namespace std;
using namespace cv;

typedef pair<int, Mat> pairImage;

class PairComp {  // An auxiliary class for sort the image pair according to its
                  // index
    public:
    bool operator()(const pairImage &n1, const pairImage &n2) const {
        if (n1.first == n2.first) return n1.first > n2.first;
        return n1.first > n2.first;
    }
};

/**
 * @brief NMS - Discard overlapping boxes using NMS
 *
 * @param box - input box vector
 * @param nms - IOU threshold
 *
 * @ret - output box vector after discarding overlapping boxes
 */
vector<vector<float>> NMS(const vector<vector<float>> &box, float nms) {
    size_t count = box.size();
    vector<pair<size_t, float>> order(count);
    for (size_t i = 0; i < count; ++i) {
        order[i].first = i;
        order[i].second = box[i][4];
    }

    sort(order.begin(), order.end(), [](const pair<int, float> &ls, const pair<int, float> &rs) {
        return ls.second > rs.second;
    });

    vector<int> keep;
    vector<bool> exist_box(count, true);
    for (size_t _i = 0; _i < count; ++_i) {
        size_t i = order[_i].first;
        float x1, y1, x2, y2, w, h, iarea, jarea, inter, ovr;
        if (!exist_box[i]) continue;
        keep.push_back(i);
        for (size_t _j = _i + 1; _j < count; ++_j) {
            size_t j = order[_j].first;
            if (!exist_box[j]) continue;
            x1 = max(box[i][0], box[j][0]);
            y1 = max(box[i][1], box[j][1]);
            x2 = min(box[i][2], box[j][2]);
            y2 = min(box[i][3], box[j][3]);
            w = max(float(0.0), x2 - x1 + 1);
            h = max(float(0.0), y2 - y1 + 1);
            iarea = (box[i][2] - box[i][0] + 1) * (box[i][3] - box[i][1] + 1);
            jarea = (box[j][2] - box[j][0] + 1) * (box[j][3] - box[j][1] + 1);
            inter = w * h;
            ovr = inter / (iarea + jarea - inter);
            if (ovr >= nms) exist_box[j] = false;
        }
    }

    vector<vector<float>> result;
    result.reserve(keep.size());
    for (size_t i = 0; i < keep.size(); ++i) {
        result.push_back(box[keep[i]]);
    }

    return result;
}

/**
 * @brief softmax_2 - 2-class softmax calculation
 *
 * @param input   - vector of input data
 * @param output  - output vecotr
 *
 * @return none
 */
void softmax_2(const vector<float> &input, vector<float> &output) {
    for (size_t n = 0; n < input.size(); n += 2) {
        float sum = 0;
        for (auto i = n; i < n + 2; i++) {
            output[i] = exp(input[i]);
            sum += output[i];
        }
        for (auto i = n; i < n + 2; i++) {
            output[i] /= sum;
        }
    }
}

/**
 * @brief runDenseBox - Run DPU Task for Densebox
 *
 * @param task - pointer to a DPU Task
 * @param img  - input image in OpenCV's Mat format
 *
 * @return none
 */
void runDenseBox(DPUTask *task, Mat &img) {
    DPUTensor *conv_in_tensor = dpuGetInputTensor(task, NODE_INPUT);
    int inHeight = dpuGetTensorHeight(conv_in_tensor);
    int inWidth = dpuGetTensorWidth(conv_in_tensor);

    float scale_w = (float)img.cols / (float)inWidth;
    float scale_h = (float)img.rows / (float)inHeight;

    dpuSetInputImage2(task, NODE_INPUT, img);

    dpuRunTask(task);

    DPUTensor *conv_out_tensor = dpuGetOutputTensor(task, NODE_CONV);
    int tensorSize = dpuGetTensorSize(conv_out_tensor);
    DPUTensor *conv_out_tensor_2 = dpuGetOutputTensor(task, NODE_OUTPUT);
    int tensorSize_2 = dpuGetTensorSize(conv_out_tensor_2);
    int outHeight_2 = dpuGetTensorHeight(conv_out_tensor_2);
    int outWidth_2 = dpuGetTensorWidth(conv_out_tensor_2);
    vector<float> pixel(tensorSize);
    vector<float> conf(tensorSize);
    vector<float> bb(tensorSize_2);

    //output data format convert
    dpuGetOutputTensorInHWCFP32(task, NODE_CONV, pixel.data(), tensorSize);
    dpuGetOutputTensorInHWCFP32(task, NODE_OUTPUT, bb.data(), tensorSize_2);

    //2-classes softmax
    softmax_2(pixel, conf);

    // get original face boxes
    vector<vector<float>> boxes;
    for (int i = 0; i < outHeight_2; i++) {
        for (int j = 0; j < outWidth_2; j++) {
            int position = i * outWidth_2 + j;
            vector<float> box;
            if (conf[position * 2 + 1] > 0.55) {
                box.push_back(bb[position * 4 + 0] + j * 4);
                box.push_back(bb[position * 4 + 1] + i * 4);
                box.push_back(bb[position * 4 + 2] + j * 4);
                box.push_back(bb[position * 4 + 3] + i * 4);
                box.push_back(conf[position * 2 + 1]);
                boxes.push_back(box);
            }
        }
    }

    // Discard overlapping boxes using NMS
    vector<vector<float>> res = NMS(boxes, 0.35);

    // Draw detected face boxes to image
    for (size_t i = 0; i < res.size(); ++i) {
        float xmin = std::max(res[i][0] * scale_w, 0.0f);
        float ymin = std::max(res[i][1] * scale_h, 0.0f);
        float xmax = std::min(res[i][2] * scale_w, (float)img.cols);
        float ymax = std::min(res[i][3] * scale_h, (float)img.rows);

        rectangle(img, Point(xmin, ymin), Point(xmax, ymax), Scalar(0, 255, 0), 1, 1, 0);
    }
}

/*
 * @brief faceDetection - Entry of face detection using Densebox
 *
 * @param kernel - point to DPU Kernel
 *
 * @return none
 */
void faceDetection(DPUKernel *kernel) {
    Mat img = imread("face.jpg");
    if(img.data == NULL){
        cerr << "Could not read face image..." << endl;
        return;
    }

    // Create DPU Tasks from DPU Kernel
    DPUTask *task = dpuCreateTask(kernel, 0);

    runDenseBox(task, img);

    if(!imwrite("face_det.jpg", img)){
        cerr << "Could not save the result..." << endl;
    }

    dpuDestroyTask(task);
}

/*
 * @brief main - Entry of DenseBox neural network sample.
 *
 * @note This sample presents how to implement an face detection appliacation
 *       on DPU using DenseBox model.
 *
 */
int main(void) {
    // Attach to DPU driver and prepare for running
    dpuOpen();

    // Load DPU Kernel for DenseBox neural network
    DPUKernel *kernel = dpuLoadKernel("densebox");

    // Doing face detection.
    faceDetection(kernel);

    // Destroy DPU Kernel & free resources
    dpuDestroyKernel(kernel);

    // Dettach from DPU driver & release resources
    dpuClose();

    return 0;
}
