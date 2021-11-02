from flask import Flask, abort , session, redirect
from flask_images import resized_img_src
from app.general.general import general_bp
from app.ajax.ajax import ajax_bp
from app.products.products import  products_bp
from app.auth.auth import auth_bp	
from app.cart.cart import cart_bp
from app.visits.visits import visits_bp
from flask_cors import CORS
import logging, sys, json_logging, flask, os
from flask_session import Session
from sqlalchemy import create_engine

dblocation = '/appdata/session.db'

if not os.path.exists(dblocation):
    print ("Creating DBEngine for sqllite KRISHNA KRISHNA KRISHNA")
    engine = create_engine('sqlite:///{}'.format(dblocation), echo = True)

print ("SQLite DB Engine created")

app = Flask(__name__)
json_logging.init_flask(enable_json=True)
json_logging.init_request_instrument(app)
cors = CORS(app)
app.secret_key = os.environ.get('SECRET_KEY', "eksAuroraGlobalDb")

app.config['SESSION_TYPE'] = 'sqlalchemy'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///{}'.format(dblocation)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = True
app.config['SESSION_PERMANENT'] = True
app.config['SESSION_USE_SIGNER'] = True
sess = Session(app)
sess.app.session_interface.db.create_all()

@app.before_request
def run():
	if 'email' in session:
		redirect("/")
	else:
		redirect("/auth/login")
app.register_blueprint(general_bp)  
app.register_blueprint(ajax_bp, url_prefix="/ajax")
app.register_blueprint(products_bp, url_prefix="/products")
app.register_blueprint(auth_bp, url_prefix="/auth")
app.register_blueprint(cart_bp, url_prefix="/cart")
app.register_blueprint(visits_bp, url_prefix="/visits")
