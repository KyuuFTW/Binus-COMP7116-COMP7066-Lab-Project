import os
import cv2
import numpy as np

def get_path_list(root_path):
    pathList = []
    for x in os.listdir(root_path):
        pathList.append(x)
    return pathList

def get_class_names(root_path, train_names):
    imagePath = []
    imageId = []
    idx = -1

    for x in train_names:
        idx += 1
        for y in os.listdir(root_path + '/' + x):
            imagePath.append(root_path + '/' + x + '/' + y)
            imageId.append(idx)

    return (imagePath, imageId)

def get_train_images_data(image_path_list):
    imageList = []
    for x in image_path_list:
        imageList.append(cv2.imread(x))
    return imageList
    
def detect_faces_and_filter(image_list, image_classes_list=None):
    fGrayImgList = []
    fRectList = []
    fImgIdList = []

    # create empty class list if image_classes_list is None
    if (image_classes_list == None):
        image_classes_list = []
        L = len(image_list)
        for i in range(L):
            image_classes_list.append(None)

    # face detector
    face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_alt.xml')

    for x, y in zip(image_list, image_classes_list):

        # grayscale
        graytmp = cv2.cvtColor(x, cv2.COLOR_BGR2GRAY)

        # detect face
        face_detect = face_cascade.detectMultiScale(graytmp, scaleFactor=1.1, minNeighbors=5)

        # more than one face or no face
        if (len(face_detect) != 1):
            continue

        # create rectangle around face and crop the grayscale
        for rect in face_detect:

            fRectList.append(rect)

            graytmp = graytmp[rect[1]:rect[1]+rect[3], rect[0]:rect[0]+rect[2]]

            # COCOKLOGI -> resize
            graytmp = cv2.resize(graytmp, (128,128))

            fGrayImgList.append(graytmp)

        fImgIdList.append(y)

    return (fGrayImgList, fRectList, fImgIdList)

def train(train_face_grays, image_classes_list):
    classifierObject = cv2.face.LBPHFaceRecognizer_create()

    classifierObject.train(train_face_grays, np.array(image_classes_list))

    return classifierObject

def get_test_images_data(test_root_path, image_path_list):
    testImageList = []

    for x in image_path_list:
        testImageList.append(cv2.imread(test_root_path + '/' + x))

    return testImageList

def predict(classifier, test_faces_gray):
    predictionList = []

    for x in test_faces_gray:
        predictionList.append(classifier.predict(x))

    return predictionList

def draw_prediction_results(predict_results, test_image_list, test_faces_rects, train_names):
    predictionDraw = []

    font = cv2.FONT_HERSHEY_SIMPLEX
    for a, b, c in zip(predict_results, test_image_list, test_faces_rects):
        cv2.rectangle(b, (c[0],c[1]), (c[0]+c[2], c[1]+c[3]), (0,255,0), 1)

        namaewa = train_names[a[0]].replace("_", " ")

        cv2.putText(b, namaewa, (c[0], c[1] - 3), font, 0.5, (0,255,0), 0, cv2.LINE_AA)
        predictionDraw.append(b)

    return predictionDraw

def combine_results(predicted_test_image_list):
    cnt = len(predicted_test_image_list)
    height = predicted_test_image_list[0].shape[0]
    width = predicted_test_image_list[0].shape[1]

    imgArray = np.zeros((height, width * cnt, 3), dtype=np.uint8)
    for i in range(cnt):
        for x in range(height):
            for y in range(width):
                imgArray[x][y + i*width] = predicted_test_image_list[i][x][y]
    
    return imgArray

def show_result(image):
    cv2.imshow('Result', image)
    cv2.waitKey()

'''
You may modify the code below if it's marked between

-------------------
Modifiable
-------------------

and

-------------------
End of modifiable
-------------------
'''
if __name__ == "__main__":
    '''
        Please modify train_root_path value according to the location of
        your data train root directory

        -------------------
        Modifiable
        -------------------
    '''
    train_root_path = "dataset/train"
    '''
        -------------------
        End of modifiable
        -------------------
    '''
    
    train_names = get_path_list(train_root_path)
    image_path_list, image_classes_list = get_class_names(train_root_path, train_names)
    train_image_list = get_train_images_data(image_path_list)
    train_face_grays, _, filtered_classes_list = detect_faces_and_filter(train_image_list, image_classes_list)
    classifier = train(train_face_grays, filtered_classes_list)

    '''
        Please modify test_image_path value according to the location of
        your data test root directory

        -------------------
        Modifiable
        -------------------
    '''
    test_root_path = "dataset/test"
    '''
        -------------------
        End of modifiable
        -------------------
    '''

    test_names = get_path_list(test_root_path)
    test_image_list = get_test_images_data(test_root_path, test_names)
    test_faces_gray, test_faces_rects, _ = detect_faces_and_filter(test_image_list)
    predict_results = predict(classifier, test_faces_gray)
    predicted_test_image_list = draw_prediction_results(predict_results, test_image_list, test_faces_rects, train_names)
    final_image_result = combine_results(predicted_test_image_list)
    show_result(final_image_result)