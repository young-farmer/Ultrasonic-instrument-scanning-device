# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'pyqtgraph_pyqt_1.ui'
#
# Created by: PyQt5 UI code generator 5.15.6
#
# WARNING: Any manual changes made to this file will be lost when pyuic5 is
# run again.  Do not edit this file unless you know what you are doing.

from PyQt5.QtCore import pyqtSignal
from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import  QDialog,  QPushButton, QVBoxLayout,QGridLayout, QLineEdit
from PyQt5 import QtCore, QtWidgets
##23—07—06添加
class VirtualKeyboard(QDialog):
    digit_pressed = pyqtSignal(str)
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Virtual Keyboard")
        self.setFixedSize(400, 200)

        self.setWindowFlags(Qt.FramelessWindowHint)
        layout = QVBoxLayout(self)
        layout.setSpacing(1)
        grid_layout = QGridLayout()
        layout.addLayout(grid_layout)
        buttons = [
            "1", "2", "3",
            "4", "5", "6",
            "7", "8", "9",
            "0", ".","Close",
            "←","Del","→"
        ]

        positions = [(i, j) for i in range(5) for j in range(3)]

        for position, button_label in zip(positions, buttons):
            button = QPushButton(button_label)
            button.setStyleSheet("QPushButton {\n"
                                  "       border-image: url(:/test1/input_.png) 10 10 10 10 stretch ;\n"
                                  "        font: 400 18pt \"Microsoft YaHei UI\" ;color: rgb(255, 255, 0);\n"
                                  "    }\n"
                                  "QPushButton:pressed{\n"
                                  "       border-image: url(:/test1/input_pressed.png) 10 10 10 10 stretch ;\n"
                                  "    color: rgb(7, 160, 255);\n"
                                  "    }\n"
                                  "")
            grid_layout.addWidget(button, *position)

            if button_label == "Close":
                button.clicked.connect(self.close)
            else:
                button.clicked.connect(lambda _, label=button_label: self.digit_pressed.emit(label))
            '''
            这句代码是用来连接按钮的点击事件（button.clicked）到信号（self.digit_pressed）的发送操作。
            在这句代码中，使用了lambda表达式来创建一个匿名函数，该函数的参数包括一个无用的占位符_和一个命名参数label。
            label=button_label表示将按钮的标签值作为参数传递给该匿名函数。
            接下来，匿名函数调用了self.digit_pressed.emit(label)，通过调用信号的emit方法来发送信号，传递了按钮的标签值作为参数。
            这样，当按钮被点击时，触发了该连接的槽函数，并将按钮的标签值作为参数传递给槽函数。
            这种用法可以使用lambda表达式结合命名参数来捕获当前循环中的变量值，并将其传递给信号的槽函数。
            '''

##23—07—06添加
class CustomLineEdit(QLineEdit):
    clicked = pyqtSignal()

    def mousePressEvent(self, event):
        super().mousePressEvent(event)
        self.clicked.emit()

class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(1280, 720)
        MainWindow.setStyleSheet("background-color: rgb(27, 48, 84);\n"
"")
        self.centralwidget = QtWidgets.QWidget(MainWindow)
        self.centralwidget.setStyleSheet("")
        self.centralwidget.setObjectName("centralwidget")
        self.tabWidget = QtWidgets.QTabWidget(self.centralwidget)
        self.tabWidget.setGeometry(QtCore.QRect(0, -10, 1291, 721))
        self.tabWidget.setMinimumSize(QtCore.QSize(0, 0))
        self.tabWidget.setStyleSheet("\n"
"QTabBar::tab:!last { \n"
"\n"
"border-image: url(:/test1/Tab_no_selected.png) 14 14 14 14 stretch;\n"
"font: 600 12pt \"Microsoft YaHei UI\" ;color: rgb(11, 58, 108);\n"
"min-width: 100px;\n"
"min-height: 130px;\n"
"border-style: none;\n"
" }\n"
"\n"
"QTabBar::tab:!last:selected {\n"
"color: rgb(207, 225, 255);\n"
"border-image: url(:/test1/Tab_selected.png) 14 14 14 14 stretch;\n"
"    }\n"
"QTabBar::tab:last { \n"
"border-image: url(:/test1/LISI_logo.png) 14 14 14 14 stretch;\n"
"font: 600 12pt \"Microsoft YaHei UI\" ;color: rgb(124, 44, 162);\n"
"min-width: 100px;\n"
"min-height: 191px;\n"
"border-style: none;\n"
" }\n"
"")
        self.tabWidget.setTabPosition(QtWidgets.QTabWidget.West)
        self.tabWidget.setTabShape(QtWidgets.QTabWidget.Rounded)
        self.tabWidget.setElideMode(QtCore.Qt.ElideMiddle)
        self.tabWidget.setDocumentMode(False)
        self.tabWidget.setTabsClosable(False)
        self.tabWidget.setMovable(False)
        self.tabWidget.setTabBarAutoHide(True)
        self.tabWidget.setObjectName("tabWidget")
        self.tab_1 = QtWidgets.QWidget()
        self.tab_1.setStyleSheet("")
        self.tab_1.setObjectName("tab_1")
        self.pyqtgraph1 = GraphicsLayoutWidget(self.tab_1)
        self.pyqtgraph1.setGeometry(QtCore.QRect(10, 20, 791, 671))
        self.pyqtgraph1.setStyleSheet("\n"
"background-color: rgb(27, 48, 84);")
        self.pyqtgraph1.setObjectName("pyqtgraph1")
        self.ch_1 = QtWidgets.QPushButton(self.pyqtgraph1)
        self.ch_1.setGeometry(QtCore.QRect(680, 70, 111, 61))
        self.ch_1.setStyleSheet("QPushButton {\n"
"       border-image: url(:/test1/input_.png) 10 10 10 10 stretch ;\n"
"        font: 400 15pt \"Microsoft YaHei UI\" ;color: rgb(255, 255, 0);\n"
"    }\n"
"QPushButton:pressed{\n"
"       border-image: url(:/test1/input_pressed.png) 10 10 10 10 stretch ;\n"
"    color: rgb(7, 160, 255);\n"
"    }\n"
"")
        self.ch_1.setObjectName("ch_1")
        self.ch_2 = QtWidgets.QPushButton(self.pyqtgraph1)
        self.ch_2.setGeometry(QtCore.QRect(680, 130, 111, 61))
        self.ch_2.setStyleSheet("QPushButton {\n"
"       border-image: url(:/test1/input_.png) 10 10 10 10 stretch ;\n"
"        font: 400 15pt \"Microsoft YaHei UI\" ;color: rgb(255, 255, 0);\n"
"    }\n"
"QPushButton:pressed{\n"
"       border-image: url(:/test1/input_pressed.png) 10 10 10 10 stretch ;\n"
"    color: rgb(7, 160, 255);\n"
"    }\n"
"")
        self.ch_2.setObjectName("ch_2")
        self.pushButton = QtWidgets.QPushButton(self.tab_1)
        self.pushButton.setGeometry(QtCore.QRect(840, 30, 321, 121))
        self.pushButton.setStyleSheet("QPushButton {\n"
"       border-image: url(:/test1/input_.png) 10 10 10 10 stretch ;\n"
"        font: 400 18pt \"Microsoft YaHei UI\" ;color: rgb(255, 255, 0);\n"
"    }\n"
"QPushButton:pressed{\n"
"       border-image: url(:/test1/input_pressed.png) 10 10 10 10 stretch ;\n"
"    color: rgb(7, 160, 255);\n"
"    }\n"
"")
        self.pushButton.setObjectName("pushButton")
        self.horizontalSlider = QtWidgets.QSlider(self.tab_1)
        self.horizontalSlider.setGeometry(QtCore.QRect(840, 200, 321, 61))
        self.horizontalSlider.setStyleSheet("    QSlider {\n"
"        background-color: rgb(27, 48, 84);\n"
"        height: 60px;\n"
"    }\n"
"    \n"
"    QSlider::groove:horizontal {\n"
"        background-color: rgb(0, 0, 239);\n"
"        height: 4px;\n"
"        border-radius: 2px;\n"
"    }\n"
"    \n"
"    QSlider::handle:horizontal {\n"
"       border-image: url(:/test1/sliding_block.png) 14 14 14 14 stretch;        \n"
"        width: 70px;\n"
"        margin: -16px 0;\n"
"    }\n"
"    \n"
"\n"
"\n"
"\n"
"")
        self.horizontalSlider.setOrientation(QtCore.Qt.Horizontal)
        self.horizontalSlider.setObjectName("horizontalSlider")
        self.horizontalSlider_2 = QtWidgets.QSlider(self.tab_1)
        self.horizontalSlider_2.setGeometry(QtCore.QRect(840, 280, 321, 51))
        self.horizontalSlider_2.setStyleSheet("    QSlider {\n"
"        background-color: rgb(27, 48, 84);\n"
"        height: 60px;\n"
"    }\n"
"    \n"
"    QSlider::groove:horizontal {\n"
"        background-color: rgb(0, 0, 239);\n"
"        height: 4px;\n"
"        border-radius: 2px;\n"
"    }\n"
"    \n"
"    QSlider::handle:horizontal {\n"
"       border-image: url(:/test1/sliding_block.png) 14 14 14 14 stretch;        \n"
"        width: 70px;\n"
"        margin: -16px 0;\n"
"    }\n"
"    \n"
"\n"
"\n"
"\n"
"")
        self.horizontalSlider_2.setOrientation(QtCore.Qt.Horizontal)
        self.horizontalSlider_2.setObjectName("horizontalSlider_2")
        self.f_s_Button = QtWidgets.QPushButton(self.tab_1)
        self.f_s_Button.setGeometry(QtCore.QRect(840, 570, 181, 101))
        self.f_s_Button.setStyleSheet("QPushButton {\n"
"       border-image: url(:/test1/input_.png) 10 10 10 10 stretch ;\n"
"        font: 400 18pt \"Microsoft YaHei UI\" ;color: rgb(255, 255, 0);\n"
"    }\n"
"QPushButton:pressed{\n"
"       border-image: url(:/test1/input_pressed.png) 10 10 10 10 stretch ;\n"
"    color: rgb(7, 160, 255);\n"
"    }\n"
"")
        self.f_s_Button.setObjectName("f_s_Button")
        self.label_11 = QtWidgets.QLabel(self.tab_1)
        self.label_11.setGeometry(QtCore.QRect(840, 520, 41, 31))
        self.label_11.setObjectName("label_11")
        self.dial_Y = QtWidgets.QDial(self.tab_1)
        self.dial_Y.setGeometry(QtCore.QRect(840, 340, 131, 111))
        self.dial_Y.setObjectName("dial_Y")
        self.groupBox = QtWidgets.QGroupBox(self.tab_1)
        self.groupBox.setGeometry(QtCore.QRect(830, 170, 341, 291))
        self.groupBox.setStyleSheet("QGroupBox {\n"
"        border: 1.5px solid red;\n"
"        border-radius: 9px;\n"
"        subcontrol-position: top center;\n"
"        font-size: 17px;\n"
"        font-weight: bold;\n"
"        color: rgb(255, 255, 127);\n"
"\n"
"    }")
        self.groupBox.setAlignment(QtCore.Qt.AlignHCenter|QtCore.Qt.AlignTop)
        self.groupBox.setObjectName("groupBox")
        self.dial_X = QtWidgets.QDial(self.groupBox)
        self.dial_X.setGeometry(QtCore.QRect(140, 170, 121, 111))
        self.dial_X.setObjectName("dial_X")
        self.pushButton_4 = QtWidgets.QPushButton(self.groupBox)
        self.pushButton_4.setGeometry(QtCore.QRect(260, 170, 61, 101))
        self.pushButton_4.setStyleSheet("QPushButton {\n"
"       border-image: url(:/test1/input_.png) 10 10 10 10 stretch ;\n"
"        font: 400 18pt \"Microsoft YaHei UI\" ;color: rgb(255, 255, 0);\n"
"    }\n"
"QPushButton:pressed{\n"
"       border-image: url(:/test1/input_pressed.png) 10 10 10 10 stretch ;\n"
"    color: rgb(7, 160, 255);\n"
"    }\n"
"")
        self.pushButton_4.setObjectName("pushButton_4")
        self.groupBox_2 = QtWidgets.QGroupBox(self.tab_1)
        self.groupBox_2.setGeometry(QtCore.QRect(830, 470, 341, 221))
        self.groupBox_2.setStyleSheet("QGroupBox {\n"
"        border: 1.5px solid red;\n"
"        border-radius: 9px;\n"
"        subcontrol-position: top center;\n"
"        font-size: 17px;\n"
"        font-weight: bold;\n"
"        color: rgb(255, 255, 127);\n"
"\n"
"    }")
        self.groupBox_2.setAlignment(QtCore.Qt.AlignCenter)
        self.groupBox_2.setObjectName("groupBox_2")
        self.frequency = CustomLineEdit(self.groupBox_2)
        self.frequency.setGeometry(QtCore.QRect(70, 50, 81, 41))
        self.frequency.setStyleSheet("background-color:   rgb(41, 74, 127);\n"
"border: 2px solid rgb(85, 85, 255); \n"
"\n"
"color: rgb(255, 255, 0);\n"
"\n"
"font-size: 17px;\n"
"")
        self.frequency.setInputMask("")
        self.frequency.setObjectName("frequency")
        self.label_12 = QtWidgets.QLabel(self.groupBox_2)
        self.label_12.setGeometry(QtCore.QRect(160, 50, 41, 31))
        self.label_12.setObjectName("label_12")
        self.label_5 = QtWidgets.QLabel(self.groupBox_2)
        self.label_5.setGeometry(QtCore.QRect(250, 50, 41, 31))
        self.label_5.setObjectName("label_5")
        self.Cycle = QtWidgets.QSpinBox(self.groupBox_2)
        self.Cycle.setGeometry(QtCore.QRect(210, 100, 111, 101))
        self.Cycle.setStyleSheet("QSpinBox{\n"
"background-color:   rgb(41, 74, 127);\n"
"border: 2px solid rgb(85, 85, 255); \n"
"color: rgb(255, 255, 0);\n"
"font-size: 40px;\n"
"text-align: center;}\n"
"QAbstractSpinBox::up-button { width: 60px; height: 49px; }\n"
"QAbstractSpinBox::down-button { width: 60px; height: 49px; }\n"
"")
        self.Cycle.setMaximum(10)
        self.Cycle.setProperty("value", 5)
        self.Cycle.setObjectName("Cycle")
        self.groupBox_2.raise_()
        self.groupBox.raise_()
        self.pyqtgraph1.raise_()
        self.pushButton.raise_()
        self.horizontalSlider.raise_()
        self.horizontalSlider_2.raise_()
        self.f_s_Button.raise_()
        self.label_11.raise_()
        self.dial_Y.raise_()
        self.tabWidget.addTab(self.tab_1, "")
        self.tab_2 = QtWidgets.QWidget()
        self.tab_2.setObjectName("tab_2")
        self.pyqtgraph1_2 = GraphicsLayoutWidget(self.tab_2)
        self.pyqtgraph1_2.setGeometry(QtCore.QRect(20, 20, 771, 481))
        self.pyqtgraph1_2.setObjectName("pyqtgraph1_2")
        self.label_10 = QtWidgets.QLabel(self.tab_2)
        self.label_10.setGeometry(QtCore.QRect(830, 70, 131, 51))
        self.label_10.setObjectName("label_10")
        self.lcdNumber = QtWidgets.QLCDNumber(self.tab_2)
        self.lcdNumber.setGeometry(QtCore.QRect(1030, 60, 111, 81))
        self.lcdNumber.setStyleSheet("color: rgb(255, 255, 127);\n"
"        QLCDNumber {\n"                                   
"            background-color: transparent;\n"
"            border: none;\n"
"            color: black;\n"
"        }\n"
"")
        self.lcdNumber.setDigitCount(2)
        self.lcdNumber.setMode(QtWidgets.QLCDNumber.Dec)
        self.lcdNumber.setProperty("value", 0.0)
        self.lcdNumber.setProperty("intValue", 0)
        self.lcdNumber.setObjectName("lcdNumber")
        self.pyqtgraph1_3 = GraphicsLayoutWidget(self.tab_2)
        self.pyqtgraph1_3.setGeometry(QtCore.QRect(20, 540, 771, 151))
        self.pyqtgraph1_3.setObjectName("pyqtgraph1_3")
        self.B_scan = QtWidgets.QPushButton(self.tab_2)
        self.B_scan.setGeometry(QtCore.QRect(820, 180, 341, 91))
        self.B_scan.setStyleSheet("QPushButton {\n"
"       border-image: url(:/test1/input_.png) 10 10 10 10 stretch ;\n"
"        font: 400 18pt \"Microsoft YaHei UI\" ;color: rgb(255, 255, 0);\n"
"    }\n"
"QPushButton:pressed{\n"
"       border-image: url(:/test1/input_pressed.png) 10 10 10 10 stretch ;\n"
"    color: rgb(7, 160, 255);\n"
"    }\n"
"")
        self.B_scan.setObjectName("B_scan")
        self.groupBox_7 = QtWidgets.QGroupBox(self.tab_2)
        self.groupBox_7.setGeometry(QtCore.QRect(820, 300, 341, 371))
        self.groupBox_7.setStyleSheet("QGroupBox {\n"
"        border: 1.5px solid red;\n"
"        border-radius: 9px;\n"
"        subcontrol-position: top center;\n"
"        font-size: 17px;\n"
"        font-weight: bold;\n"
"        color: rgb(255, 255, 127);\n"
"\n"
"    }")
        self.groupBox_7.setObjectName("groupBox_7")
        self.dateEdit = QtWidgets.QDateEdit(self.groupBox_7)
        self.dateEdit.setGeometry(QtCore.QRect(20, 80, 301, 51))
        self.dateEdit.setStyleSheet("QDateEdit{\n"
"background-color:   rgb(41, 74, 127);\n"
"border: 2px solid rgb(85, 85, 255); \n"
"color: rgb(255, 255, 0);\n"
"font-size: 25px;\n"
"text-align: center;}\n"
"")
        self.dateEdit.setDateTime(QtCore.QDateTime(QtCore.QDate(2022, 12, 31), QtCore.QTime(16, 0, 0)))
        self.dateEdit.setObjectName("dateEdit")
        self.pushButton_2 = QtWidgets.QPushButton(self.groupBox_7)
        self.pushButton_2.setGeometry(QtCore.QRect(20, 280, 301, 61))
        self.pushButton_2.setStyleSheet("QPushButton {\n"
"       border-image: url(:/test1/input_.png) 10 10 10 10 stretch ;\n"
"        font: 400 18pt \"Microsoft YaHei UI\" ;color: rgb(255, 255, 0);\n"
"    }\n"
"QPushButton:pressed{\n"
"       border-image: url(:/test1/input_pressed.png) 10 10 10 10 stretch ;\n"
"    color: rgb(7, 160, 255);\n"
"    }\n"
"")
        self.pushButton_2.setObjectName("pushButton_2")
        self.lineEdit = QtWidgets.QLineEdit(self.groupBox_7)
        self.lineEdit.setGeometry(QtCore.QRect(20, 220, 301, 41))
        self.lineEdit.setStyleSheet("background-color:   rgb(41, 74, 127);\n"
"border: 2px solid rgb(85, 85, 255); \n"
"\n"
"color: rgb(255, 255, 0);\n"
"\n"
"font-size: 17px;\n"
"")
        self.lineEdit.setObjectName("lineEdit")
        self.radioButton_3 = QtWidgets.QRadioButton(self.groupBox_7)
        self.radioButton_3.setGeometry(QtCore.QRect(270, 170, 61, 20))
        self.radioButton_3.setStyleSheet("selection-background-color: rgb(85, 170, 255);\n"
"\n"
"color: rgb(255, 255, 0);\n"
"\n"
"font-size: 17px;")
        self.radioButton_3.setObjectName("radioButton_3")
        self.radioButton = QtWidgets.QRadioButton(self.groupBox_7)
        self.radioButton.setGeometry(QtCore.QRect(20, 170, 61, 20))
        self.radioButton.setStyleSheet("selection-background-color: rgb(85, 170, 255);\n"
"\n"
"color: rgb(255, 255, 0);\n"
"\n"
"font-size: 17px;")
        self.radioButton.setObjectName("radioButton")
        self.radioButton_2 = QtWidgets.QRadioButton(self.groupBox_7)
        self.radioButton_2.setGeometry(QtCore.QRect(150, 170, 61, 20))
        self.radioButton_2.setStyleSheet("selection-background-color: rgb(85, 170, 255);\n"
"\n"
"color: rgb(255, 255, 0);\n"
"\n"
"font-size: 17px;")
        self.radioButton_2.setObjectName("radioButton_2")
        self.groupBox_7.raise_()
        self.pyqtgraph1_2.raise_()
        self.pyqtgraph1_3.raise_()
        self.B_scan.raise_()
        self.tabWidget.addTab(self.tab_2, "")
        self.tab = QtWidgets.QWidget()
        self.tab.setStyleSheet("")
        self.tab.setObjectName("tab")
        self.Data_show = QtWidgets.QTextBrowser(self.tab)
        self.Data_show.setGeometry(QtCore.QRect(800, 80, 351, 591))
        self.Data_show.setStyleSheet("background-color:   rgb(41, 74, 127);\n"
"border: 2px solid rgb(85, 85, 255); \n"
"\n"
"color: rgb(255, 255, 0);\n"
"\n"
"font-size: 17px;\n"
"")
        self.Data_show.setObjectName("Data_show")
        self.groupBox_3 = QtWidgets.QGroupBox(self.tab)
        self.groupBox_3.setGeometry(QtCore.QRect(20, 470, 741, 221))
        self.groupBox_3.setStyleSheet("QGroupBox {\n"
"        border: 1.5px solid red;\n"
"        border-radius: 9px;\n"
"        subcontrol-position: top center;\n"
"        font-size: 17px;\n"
"        font-weight: bold;\n"
"        color: rgb(255, 255, 127);\n"
"\n"
"    }")
        self.groupBox_3.setObjectName("groupBox_3")
        self.Datasend = QtWidgets.QLineEdit(self.groupBox_3)
        self.Datasend.setGeometry(QtCore.QRect(20, 30, 461, 51))
        self.Datasend.setStyleSheet("background-color:   rgb(41, 74, 127);\n"
"border: 2px solid rgb(85, 85, 255); \n"
"\n"
"color: rgb(255, 255, 0);\n"
"\n"
"font-size: 17px;\n"
"")
        self.Datasend.setText("")
        self.Datasend.setObjectName("Datasend")
        self.command_tx = QtWidgets.QPushButton(self.groupBox_3)
        self.command_tx.setGeometry(QtCore.QRect(510, 30, 221, 51))
        self.command_tx.setStyleSheet("QPushButton {\n"
"       border-image: url(:/test1/input_.png) 10 10 10 10 stretch ;\n"
"        font: 400 18pt \"Microsoft YaHei UI\" ;color: rgb(255, 255, 0);\n"
"    }\n"
"QPushButton:pressed{\n"
"       border-image: url(:/test1/input_pressed.png) 10 10 10 10 stretch ;\n"
"    color: rgb(7, 160, 255);\n"
"    }\n"
"")
        self.command_tx.setObjectName("command_tx")
        self.UartText = QtWidgets.QTextBrowser(self.groupBox_3)
        self.UartText.setGeometry(QtCore.QRect(20, 100, 711, 111))
        self.UartText.setStyleSheet("background-color:   rgb(41, 74, 127);\n"
"border: 2px solid rgb(85, 85, 255); \n"
"\n"
"color: rgb(255, 255, 0);\n"
"\n"
"font-size: 17px;\n"
"")
        self.UartText.setObjectName("UartText")
        self.groupBox_4 = QtWidgets.QGroupBox(self.tab)
        self.groupBox_4.setGeometry(QtCore.QRect(790, 40, 371, 651))
        self.groupBox_4.setStyleSheet("QGroupBox {\n"
"        border: 1.5px solid red;\n"
"        border-radius: 9px;\n"
"        subcontrol-position: top center;\n"
"        font-size: 17px;\n"
"        font-weight: bold;\n"
"        color: rgb(255, 255, 127);\n"
"\n"
"    }")
        self.groupBox_4.setObjectName("groupBox_4")
        self.groupBox_5 = QtWidgets.QGroupBox(self.tab)
        self.groupBox_5.setGeometry(QtCore.QRect(20, 220, 741, 241))
        self.groupBox_5.setStyleSheet("QGroupBox {\n"
"        border: 1.5px solid red;\n"
"        border-radius: 9px;\n"
"        subcontrol-position: top center;\n"
"        font-size: 17px;\n"
"        font-weight: bold;\n"
"        color: rgb(255, 255, 127);\n"
"\n"
"    }")
        self.groupBox_5.setObjectName("groupBox_5")
        self.UartText_2 = QtWidgets.QTextBrowser(self.groupBox_5)
        self.UartText_2.setGeometry(QtCore.QRect(20, 30, 601, 192))
        self.UartText_2.setStyleSheet("background-color:   rgb(41, 74, 127);\n"
"border: 2px solid rgb(85, 85, 255); \n"
"\n"
"color: rgb(255, 255, 0);\n"
"\n"
"font-size: 17px;\n"
"")
        self.UartText_2.setObjectName("UartText_2")
        self.device_ac = QtWidgets.QPushButton(self.groupBox_5)
        self.device_ac.setGeometry(QtCore.QRect(640, 30, 91, 191))
        self.device_ac.setStyleSheet("QPushButton {\n"
"       border-image: url(:/test1/input_.png) 10 10 10 10 stretch ;\n"
"        font: 400 18pt \"Microsoft YaHei UI\" ;color: rgb(255, 255, 0);\n"
"    }\n"
"QPushButton:pressed{\n"
"       border-image: url(:/test1/input_pressed.png) 10 10 10 10 stretch ;\n"
"    color: rgb(7, 160, 255);\n"
"    }\n"
"")
        self.device_ac.setObjectName("device_ac")
        self.groupBox_6 = QtWidgets.QGroupBox(self.tab)
        self.groupBox_6.setGeometry(QtCore.QRect(20, 40, 741, 171))
        self.groupBox_6.setStyleSheet("QGroupBox {\n"
"        border: 1.5px solid red;\n"
"        border-radius: 9px;\n"
"        subcontrol-position: top center;\n"
"        font-size: 17px;\n"
"        font-weight: bold;\n"
"        color: rgb(255, 255, 127);\n"
"\n"
"    }")
        self.groupBox_6.setObjectName("groupBox_6")
        self.label_2 = QtWidgets.QLabel(self.groupBox_6)
        self.label_2.setGeometry(QtCore.QRect(20, 40, 201, 31))
        self.label_2.setObjectName("label_2")
        self.comsetBox = QtWidgets.QComboBox(self.groupBox_6)
        self.comsetBox.setGeometry(QtCore.QRect(20, 90, 201, 51))
        self.comsetBox.setStyleSheet("\n"
"QComboBox{\n"
"background-color:   rgb(41, 74, 127);\n"
"border: 2px solid rgb(85, 85, 255); \n"
"color: rgb(255, 255, 0);\n"
"font-size: 20px;\n"
"text-align: center;}\n"
"\n"
"")
        self.comsetBox.setInsertPolicy(QtWidgets.QComboBox.InsertAtBottom)
        self.comsetBox.setObjectName("comsetBox")
        self.comsetBox.addItem("")
        self.comsetBox.addItem("")
        self.comsetBox.addItem("")
        self.comsetBox.addItem("")
        self.comsetBox.addItem("")
        self.comsetBox.addItem("")
        self.comsetBox.addItem("")
        self.comsetBox.addItem("")
        self.comsetBox.addItem("")
        self.comsetBox.addItem("")
        self.comsetBox.addItem("")
        self.comsetBox.addItem("")
        self.comsetBox.addItem("")
        self.comsetBox.addItem("")
        self.comsetBox.addItem("")
        self.comsetBox.addItem("")
        self.label_3 = QtWidgets.QLabel(self.groupBox_6)
        self.label_3.setGeometry(QtCore.QRect(280, 40, 171, 21))
        self.label_3.setObjectName("label_3")
        self.comsetBox_2 = QtWidgets.QComboBox(self.groupBox_6)
        self.comsetBox_2.setGeometry(QtCore.QRect(280, 90, 201, 51))
        self.comsetBox_2.setStyleSheet("\n"
"QComboBox{\n"
"background-color:   rgb(41, 74, 127);\n"
"border: 2px solid rgb(85, 85, 255); \n"
"color: rgb(255, 255, 0);\n"
"font-size: 20px;\n"
"text-align: center;}\n"
"\n"
"")
        self.comsetBox_2.setObjectName("comsetBox_2")
        self.comsetBox_2.addItem("")
        self.comsetBox_2.addItem("")
        self.comsetBox_2.addItem("")
        self.comsetBox_2.addItem("")
        self.comsetBox_2.addItem("")
        self.opencom = QtWidgets.QPushButton(self.groupBox_6)
        self.opencom.setGeometry(QtCore.QRect(530, 100, 191, 51))
        self.opencom.setStyleSheet("QPushButton {\n"
"       border-image: url(:/test1/input_.png) 10 10 10 10 stretch ;\n"
"        font: 400 18pt \"Microsoft YaHei UI\" ;color: rgb(255, 255, 0);\n"
"    }\n"
"QPushButton:pressed{\n"
"       border-image: url(:/test1/input_pressed.png) 10 10 10 10 stretch ;\n"
"    color: rgb(7, 160, 255);\n"
"    }\n"
"")
        self.opencom.setObjectName("opencom")
        self.closecom = QtWidgets.QPushButton(self.groupBox_6)
        self.closecom.setGeometry(QtCore.QRect(530, 30, 191, 51))
        self.closecom.setStyleSheet("QPushButton {\n"
"       border-image: url(:/test1/input_.png) 10 10 10 10 stretch ;\n"
"        font: 400 18pt \"Microsoft YaHei UI\" ;color: rgb(255, 255, 0);\n"
"    }\n"
"QPushButton:pressed{\n"
"       border-image: url(:/test1/input_pressed.png) 10 10 10 10 stretch ;\n"
"    color: rgb(7, 160, 255);\n"
"    }\n"
"")
        self.closecom.setObjectName("closecom")
        self.groupBox_6.raise_()
        self.groupBox_5.raise_()
        self.groupBox_4.raise_()
        self.groupBox_3.raise_()
        self.Data_show.raise_()
        self.tabWidget.addTab(self.tab, "")
        self.tab_3 = QtWidgets.QWidget()
        self.tab_3.setObjectName("tab_3")
        self.tabWidget.addTab(self.tab_3, "")
        self.tab_4 = QtWidgets.QWidget()
        self.tab_4.setObjectName("tab_4")
        self.pushButton_3 = QtWidgets.QPushButton(self.tab_4)
        self.pushButton_3.setGeometry(QtCore.QRect(30, 30, 75, 24))
        self.pushButton_3.setObjectName("pushButton_3")
        self.tabWidget.addTab(self.tab_4, "")
        MainWindow.setCentralWidget(self.centralwidget)
        self.statusbar = QtWidgets.QStatusBar(MainWindow)
        self.statusbar.setObjectName("statusbar")
        MainWindow.setStatusBar(self.statusbar)

        self.retranslateUi(MainWindow)
        self.tabWidget.setCurrentIndex(0)
        self.horizontalSlider.actionTriggered['int'].connect(MainWindow.slot1) # type: ignore
        self.horizontalSlider_2.actionTriggered['int'].connect(MainWindow.slot1)
        self.frequency.clicked.connect(MainWindow.slot2)
        self.pushButton_3.clicked.connect(self.toggle_fullscreen)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "MainWindow"))
        self.ch_1.setText(_translate("MainWindow", "通道一"))
        self.ch_2.setText(_translate("MainWindow", "通道二"))
        self.pushButton.setText(_translate("MainWindow", "开始激励"))
        self.f_s_Button.setText(_translate("MainWindow", "改变参数"))
        self.label_11.setText(_translate("MainWindow", "<html><head/><body><p><span style=\" font-size:14pt; color:#ffff00;\">频率</span></p></body></html>"))
        self.groupBox.setTitle(_translate("MainWindow", "激励波形显示"))
        self.pushButton_4.setText(_translate("MainWindow", "滤波"))
        self.groupBox_2.setTitle(_translate("MainWindow", "激励参数设置"))
        self.frequency.setText(_translate("MainWindow", "250"))
        self.label_12.setText(_translate("MainWindow", "<html><head/><body><p><span style=\" font-size:12pt; color:#ffff00;\">Hz</span></p></body></html>"))
        self.label_5.setText(_translate("MainWindow", "<html><head/><body><p><span style=\" font-size:14pt; color:#ffff00;\">周期</span></p></body></html>"))
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.tab_1), _translate("MainWindow", "激励参数设置"))
        self.label_10.setText(_translate("MainWindow", "<html><head/><body><p><span style=\" font-size:18pt; color:#ffff00;\">编码器值</span></p></body></html>"))
        self.B_scan.setText(_translate("MainWindow", "开始扫查采集"))
        self.groupBox_7.setTitle(_translate("MainWindow", "导出数据"))
        self.pushButton_2.setText(_translate("MainWindow", "导出图像"))
        self.lineEdit.setText(_translate("MainWindow", "文件路径"))
        self.radioButton_3.setText(_translate("MainWindow", ".png"))
        self.radioButton.setText(_translate("MainWindow", ".tif"))
        self.radioButton_2.setText(_translate("MainWindow", ".jpg"))
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.tab_2), _translate("MainWindow", "B扫查图像"))
        self.groupBox_3.setTitle(_translate("MainWindow", "设备串口命令发送"))
        self.command_tx.setText(_translate("MainWindow", "发送"))
        self.groupBox_4.setTitle(_translate("MainWindow", "设备通讯数据流显示"))
        self.groupBox_5.setTitle(_translate("MainWindow", "上位机串口设备列表"))
        self.device_ac.setText(_translate("MainWindow", "获取"))
        self.groupBox_6.setTitle(_translate("MainWindow", "串口通讯设置"))
        self.label_2.setText(_translate("MainWindow", "<html><head/><body><p><span style=\" font-size:14pt; color:#ffff00;\">设置接收端口</span></p></body></html>"))
        self.comsetBox.setItemText(0, _translate("MainWindow", "/dev/ttyUSB0"))
        self.comsetBox.setItemText(1, _translate("MainWindow", "com12"))
        self.comsetBox.setItemText(2, _translate("MainWindow", "com11"))
        self.comsetBox.setItemText(3, _translate("MainWindow", "com10"))
        self.comsetBox.setItemText(4, _translate("MainWindow", "com9"))
        self.comsetBox.setItemText(5, _translate("MainWindow", "com8"))
        self.comsetBox.setItemText(6, _translate("MainWindow", "com7"))
        self.comsetBox.setItemText(7, _translate("MainWindow", "com6"))
        self.comsetBox.setItemText(8, _translate("MainWindow", "com5"))
        self.comsetBox.setItemText(9, _translate("MainWindow", "com4"))
        self.comsetBox.setItemText(10, _translate("MainWindow", "com3"))
        self.comsetBox.setItemText(11, _translate("MainWindow", "com2"))
        self.comsetBox.setItemText(12, _translate("MainWindow", "com14"))
        self.comsetBox.setItemText(13, _translate("MainWindow", "/dev/ttyS3"))
        self.comsetBox.setItemText(14, _translate("MainWindow", "/dev/ttyUSB1"))
        self.comsetBox.setItemText(15, _translate("MainWindow", "/dev/ttyUSB"))
        self.label_3.setText(_translate("MainWindow", "<html><head/><body><p><span style=\" font-size:14pt; color:#ffff00;\">设置接收波特率</span></p></body></html>"))
        self.comsetBox_2.setItemText(0, _translate("MainWindow", "9600"))
        self.comsetBox_2.setItemText(1, _translate("MainWindow", "19200"))
        self.comsetBox_2.setItemText(2, _translate("MainWindow", "57600"))
        self.comsetBox_2.setItemText(3, _translate("MainWindow", "38400"))
        self.comsetBox_2.setItemText(4, _translate("MainWindow", "115200"))
        self.opencom.setText(_translate("MainWindow", "打开端口"))
        self.closecom.setText(_translate("MainWindow", "关闭端口"))
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.tab), _translate("MainWindow", "通讯命令调试"))
        self.tabWidget.setTabText(self.tabWidget.indexOf(self.tab_3), _translate("MainWindow", "系统版本"))
        self.pushButton_3.setText(_translate("MainWindow", "test"))
from pyqtgraph import GraphicsLayoutWidget
import photo
