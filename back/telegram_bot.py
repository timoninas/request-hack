import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore


cred = credentials.Certificate('/Users/mac-home/Desktop/c_tp/bot/user-system-8e6f9-firebase-adminsdk-z6wlf-2104e6765d.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

import datetime
import telebot
dUserState = dict()
dUserProblem = dict()
dUserNumber = dict()
dUserEmail = dict()
token = '1207357105:AAHlQ1stw2VZd1bEvqQYLIx49nAHlOUaaRU'
bot = telebot.TeleBot(token)
x = 2
@bot.message_handler(content_types=["text"])

def ans(message):
    global x

    if message.from_user.id not in dUserState:
        dUserState[message.from_user.id] = 0

    if dUserState[message.from_user.id] == 0:
        bot.send_message(message.from_user.id, "Напишите ваш email")
        dUserState[message.from_user.id] = 1
    
    elif dUserState[message.from_user.id] == 0:
        bot.send_message(message.from_user.id, "Напишите email вашей техподдержки")
        dUserState[message.from_user.id] = 1
    
    elif dUserState[message.from_user.id] == 1:
        dUserEmail[message.from_user.id] = message.text
        dUserState[message.from_user.id] = 2
        bot.send_message(message.from_user.id, "Опишите вашу заявку")
    
    elif  dUserState[message.from_user.id] == 2:
        dUserProblem[message.from_user.id] = message.text
        dUserState[message.from_user.id] = 3
        
        sender = str(dUserEmail[message.from_user.id])
        
        receiver = "BotName"
        
        description = str(dUserProblem[message.from_user.id])
        
        date = str(datetime.datetime.now())
        

        doc_ref = db.collection(u'requests').document(str(x))
        doc_ref.set({
            u'sender': sender,
            u'receiver': receiver,
            u'description': description,
            u'date': date,
            u'isDone': 0,
        })

        x += 1
      
        bot.send_message(message.from_user.id, "Мы добавили вашу заявку")
        dUserState[message.from_user.id] = 0

if __name__ == '__main__':
    bot.polling(none_stop=True)
