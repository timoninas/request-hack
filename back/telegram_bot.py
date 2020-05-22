import firebase_admin
import datetime
import telebot
from firebase_admin import credentials
from firebase_admin import firestore
from random import choice
from string import ascii_uppercase

cred = credentials.Certificate('/Users/mac-home/Desktop/c_tp/bot/user-system-8e6f9-firebase-adminsdk-z6wlf-2104e6765d.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

dUserState = dict()
dUserProblem = dict()
dUserNumber = dict()
dUserEmail = dict()
dSupportEmail = dict()
dEquipment = db.collection(u'additional').document('equipment').get().to_dict()['list']
dFAQ = db.collection(u'additional').document('faq').get().to_dict()['list']
dQuestion = dict()
dDirector = dict()

token = '1207357105:AAHlQ1stw2VZd1bEvqQYLIx49nAHlOUaaRU'
bot = telebot.TeleBot(token)
@bot.message_handler(content_types=["text"])

def ans(message):
    
    if message.from_user.id not in dUserState:
        dUserState[message.from_user.id] = 0

    if dUserState[message.from_user.id] == 0:
        string = "Чем мы можем вам помочь?"
        ind = 0
        for key, value in dFAQ.items():
            ind += 1
            string += "\n" + str(ind) + ": " + str(key)
            dQuestion[ind] = str(value)
        string += "\n\n" + str(len(dFAQ) + 1) + ": Хотите заказать оборудование?"
        string += "\n" + str(len(dFAQ) + 2) + ": Другое"
        bot.send_message(message.from_user.id, string)
        dUserState[message.from_user.id] = 1
    
    elif dUserState[message.from_user.id] == 1:
        answer = message.text
        string = "Чем мы можем вам помочь?"
        ind = 0
        for key, value in dFAQ.items():
            ind += 1
            string += "\n" + str(ind) + ": " + str(key)
            dQuestion[ind] = str(value)
        string += "\n\n" + str(len(dFAQ) + 1) + ": Хотите заказать оборудование?"
        string += "\n" + str(len(dFAQ) + 2) + ": Другое"
        
        if not answer.isdigit() or int(answer) > len(dFAQ) + 2 or int(answer) < 1:
            bot.send_message(message.from_user.id, "Некорректный ввод" + "\n\nОстались вопросы?\n\n" + string)
        elif int(answer) == len(dFAQ) + 1:
            answer = int(answer)
            equipment_str = "Каталог доступного оборудования"
            ind = 0
            for key, value in dEquipment.items():
                ind += 1
                equipment_str += "\n" + str(ind) + ": " + str(key) + " - " + str(value) + " руб."
            equipment_str += "\n\n" + str(len(dEquipment) + 1) + ": Другое"
            bot.send_message(message.from_user.id, equipment_str)
            dUserState[message.from_user.id] = 5
        elif int(answer) == len(dFAQ) + 2:
            answer = int(answer)
            bot.send_message(message.from_user.id, "Опишите вашу проблему")
            dUserState[message.from_user.id] = 2
        else:
            answer = int(answer)
            bot.send_message(message.from_user.id, dQuestion[answer] + "\n\nОстались вопросы?\n\n" + string)
    
    elif dUserState[message.from_user.id] == 5:
        answer = message.text
        string = "Чем мы можем вам помочь?"
        ind = 0
        for key, value in dFAQ.items():
            ind += 1
            string += "\n" + str(ind) + ": " + str(key)
            dQuestion[ind] = str(value)
        string += "\n\n" + str(len(dFAQ) + 1) + ": Хотите заказать оборудование?"
        string += "\n" + str(len(dFAQ) + 2) + ": Другое"

        if not answer.isdigit() or int(answer) > len(dEquipment) + 1 or int(answer) < 1:
            bot.send_message(message.from_user.id, "Некорректный ввод" + "\n\nОстались вопросы?\n\n" + string)
            dUserState[message.from_user.id] = 1
        elif int(answer) == len(dEquipment) + 1:
            answer = int(answer)
            bot.send_message(message.from_user.id, "Напишите, какое оборудование вам требуется")
            dUserState[message.from_user.id] = 2
        else:
            answer = int(answer)
            title = list(dEquipment.keys())[answer - 1]
            price = list(dEquipment.values())[answer - 1]
            answer_string = "Прошу выдать мне оборудование " + str(title) + ", цена - " + str(price)
            dUserProblem[message.from_user.id] = answer_string
            if float(price) > 100000:
                bot.send_message(message.from_user.id, "Напишите почту вашего руководителя, чтобы мы могли подтвердить у него вашу заявку")
                dUserState[message.from_user.id] = 6
            else:
                bot.send_message(message.from_user.id, "Напишите ваш email")
                dUserState[message.from_user.id] = 3
            
    
    elif dUserState[message.from_user.id] == 6:
        dDirector[message.from_user.id] = message.text
        bot.send_message(message.from_user.id, "Напишите ваш email")
        dUserState[message.from_user.id] = 3
    
    elif dUserState[message.from_user.id] == 2:
        dUserProblem[message.from_user.id] = message.text
        bot.send_message(message.from_user.id, "Напишите ваш email")
        dUserState[message.from_user.id] = 3
    
    elif dUserState[message.from_user.id] == 3:
        dUserEmail[message.from_user.id] = message.text
        bot.send_message(message.from_user.id, "Напишите email вашей техподдержки")
        dUserState[message.from_user.id] = 4
    
    elif  dUserState[message.from_user.id] == 4:
        dSupportEmail[message.from_user.id] = message.text
        
        sender = str(dUserEmail[message.from_user.id])
        receiver = str(dSupportEmail[message.from_user.id])
        description = str(dUserProblem[message.from_user.id])
        director = str(dDirector[message.from_user.id]) if message.from_user.id in dDirector else ""
        date = str(datetime.datetime.now())

        document_name = ''.join(choice(ascii_uppercase) for i in range(12))
        doc_ref = db.collection(u'requests').document(document_name)
        doc_ref.set({
            u'sender': sender,
            u'receiver': receiver,
            u'description': description,
            u'date': date,
            u'isDone': 0,
            u'director': director,
        })
      
        bot.send_message(message.from_user.id, "Ваша заявка находится в обработке")
        dUserState[message.from_user.id] = 0

if __name__ == '__main__':
    bot.polling(none_stop=True)
