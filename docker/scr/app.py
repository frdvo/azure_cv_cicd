from io import BytesIO
import os

from flask import Flask, render_template, request, redirect
from dotenv import load_dotenv

from utils import allowed_extention, analyse_image

load_dotenv()

SUBSCRIPTION_KEY  = os.environ.get("SUBSCRIPTION_KEY", False)
END_POINT = os.environ.get("END_POINT", False)

# TODO

# 1. streach create a class to manage image encode decode state.
# 2. Flash message image extension not allow

app = Flask(__name__)

@app.route('/')
def hello_world():
    return "hello"


@app.route("/upload-image", methods=["GET", "POST"])
def upload_image():
    if request.method == "POST":

        if request.files:

            image = request.files["image"]

            if not allowed_extention(image.filename):
                print("file extention not allowed")
                return redirect(request.url)

            im = image.read()

            buffered_img = BytesIO(im)

            (encoded_img_data, 
            processed_img_data, 
            brands_detected, 
            metadata)= analyse_image(im, buffered_img, END_POINT, SUBSCRIPTION_KEY)

    
            return render_template("brand.html", img_data=encoded_img_data.decode('utf-8')
                                    ,img_data2=processed_img_data.decode('utf-8')
                                    ,brands_detected=brands_detected 
                                     , metadata=metadata)


    return render_template("upload_image.html")
    
if __name__ == "__main__":

    app.run(host='0.0.0.0',port=5000)