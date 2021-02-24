import base64
from collections import defaultdict
import os

import numpy as np
import cv2

from azure.cognitiveservices.vision.computervision import ComputerVisionClient
from msrest.authentication import CognitiveServicesCredentials


ALLOWED_EXTENSIONS = ['.jpg', '.jpeg', '.png']


def allowed_extention(filename):
    return True if os.path.splitext(filename)[-1].lower() in ALLOWED_EXTENSIONS else False


def analyse_image(byte_image, buffered_img, END_POINT, SUBSCRIPTION_KEY):

    computervision_client = ComputerVisionClient(END_POINT, CognitiveServicesCredentials(SUBSCRIPTION_KEY))
    
    analysis_type = ["brands"]
    
    image_analysis = computervision_client.analyze_image_in_stream(buffered_img, analysis_type)

    nparr = np.frombuffer(byte_image, np.uint8)
    cv2_image = cv2.imdecode(nparr,flags=1) 

    processed_img = cv2_image.copy()

    brands = [brand.name for brand in image_analysis.brands]

    brands_detected = len(brands)

    metadata = list()


    if brands ==0:
        print("no brands detected")
    else:
        for i, brand in enumerate(image_analysis.brands):
            cv2.rectangle(processed_img, (brand.rectangle.x, brand.rectangle.y), 
                        (brand.rectangle.x+brand.rectangle.w, brand.rectangle.y+brand.rectangle.h), (0, 0, 255), 2)
            cv2.putText(processed_img, brand.name, (brand.rectangle.x-5, brand.rectangle.y-5), 
	                 cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)
            metadata.append((i+1, brand.name, brand.confidence))
            
    # Convert captured image to JPG
    _ , buffer = cv2.imencode('.jpg', processed_img)

    # Convert to base64 encoding and show start of data
    processed_img_data = base64.b64encode(buffer)

    encoded_img_data = base64.b64encode(byte_image)

    return encoded_img_data, processed_img_data, brands_detected, metadata
