from flask import Flask, session, Blueprint, render_template, request, jsonify, url_for, redirect, Response
import jsonify
import requests
import json
import os
from .. import models

general_bp = Blueprint("general_bp", __name__ , template_folder="templates/general", static_url_path="/static")
@general_bp.route("/")
def home():
    products = models.Product("fashion")
    response = products.popular_items()
    if response.status_code != 200:
       abort(401)
    popular_items = response.json().get('product_items')
    return render_template("index.html", title="Home", products=popular_items)

@general_bp.route("/apiproduct", methods = ['get'])
def apiproduct():
	return {"id": "octank"}, 200

@general_bp.route("/analytic")
def analytics():
        pass
