'''

23-06-25:测试正常运行（USB波形传输功能）
23-07-06:USB2.0；串口传输均正常，激励面板编写完成
23-07-06:调试串口通讯，切换通道
23-07-16:完成界面编写
'''
# -*- coding: utf-8 -*-
from PyQt5.QtCore import QPropertyAnimation, QRect
from PyQt5.QtCore import pyqtSlot as Slot
from PyQt5.QtWidgets import QMainWindow, QApplication
import pyqtgraph as pg
from ui_23_07_15 import Ui_MainWindow,CustomLineEdit,VirtualKeyboard
import numpy as np
from PyQt5.QtCore import QTimer
import serial  # 导入串口包
import time  # 导入时间包
import serial.tools.list_ports
import usb.util
from scipy.signal import medfilt
import matplotlib.cm as cm
dev = usb.core.find(idVendor=0x04B4, idProduct=0x00F1)#USB\VID_04B4&PID_00F1设置usb连接
dev.set_configuration()


# 应用滤波器

#创建通讯类
class Uart():
    def __init__(self,**kwargs):
        self.__com = kwargs.get('com')
        self.__Baud = kwargs.get('Baud')
        self.conncent=serial.Serial(self.__com, self.__Baud, timeout=0.5)#创建com口连接
    def input_date(self,tim):
        self.conncent.flushInput()  # 清空缓冲区
        while True:
            count = self.conncent.inWaiting()  # 获取串口缓冲区数据
            if count != 0:
                time.sleep(tim)
                break
        recv = self.conncent.read(self.conncent.in_waiting)
        return recv
    def send_date(self,date):
        return self.conncent.write(date)

class MainWindow(QMainWindow, Ui_MainWindow):
    def __init__(self, parent=None):
        super(MainWindow, self).__init__(parent)

        pg.setConfigOption('background', '#002254')  # 设置背景为灰色
        pg.setConfigOption('foreground', '#ffff7f')  # 设置前景（包括坐标轴，线条，文本等等）为黑色。
        pg.setConfigOptions(antialias=True)  # 使曲线看起来更光滑，而不是锯齿状
        self.fil = 0
        self.X = 0  # X坐标调节参数
        self.X_din = 512  # X坐标调节参数
        self.Y = 0  # Y坐标调节参数
        self.Y_din = 512  # Y坐标调节参数
        self.p = np.zeros((2,6400), dtype=int)
        self.conncent=None
        self.time=0.3
        self.setupUi(self)

        #self.filter = signal.gaussian(3, std=1)

    def on_opencom_pressed(self):
        com= self.comsetBox.currentText()
        Baud = self.comsetBox_2.currentText()
        self.conncent=Uart(com=com,Baud=Baud)
    def on_device_ac_pressed(self):
        ports = serial.tools.list_ports.comports()
        for port, desc, hwid in sorted(ports):
            g=str("{}: {} [{}]\n".format(port, desc,hwid))
            text = self.UartText_2.toPlainText()  # 获取当前文本框中的文本内容
            self.UartText_2.setPlainText(text + "\n" + g)  # 更新文本框的文本内容，保留原有的文本并在末尾添加新的文本
    def on_f_s_Button_pressed(self):
        fre=self.frequency.text()
        fre=int(str(fre))
        cyc=self.Cycle.text()
        cyc=int(str(cyc))
        fre_num=4294967296*(fre/50000000)
        time=4294967296/fre_num
        hexadecimal_number = '%0*X' % (8, int(fre_num))
        hexadecimal_number_c = '%0*X' % (4, cyc*int(time))

        self.conncent.send_date(bytes.fromhex('AA0308'+hexadecimal_number[4:8]+'88'))
        self.conncent.send_date(bytes.fromhex('AA0307' + hexadecimal_number[0:4] + '88'))
        self.conncent.send_date(bytes.fromhex('AA030E' + hexadecimal_number_c + '88'))
    def slot1(self):
        self.X = self.horizontalSlider.value()*100
        self.X_din=self.dial_X.value()*100
        self.Y = self.horizontalSlider_2.value()*10
        self.Y_din=self.dial_Y.value()*3
    def slot2(self):
        virtual_keyboard = VirtualKeyboard(self)
        # 调整滑动的距离
        slide_distance = 100
        virtual_keyboard.setGeometry(QRect(500,1000, self.width(), virtual_keyboard.height()))
        animation = QPropertyAnimation(virtual_keyboard, b"geometry")
        animation.setDuration(400)
        animation.setStartValue(virtual_keyboard.geometry())
        animation.setEndValue(QRect(500,500, self.width(), virtual_keyboard.height()))
        animation.start()
        virtual_keyboard.digit_pressed.connect(self.update_label)
        virtual_keyboard.exec_()
        #print('1')
    def update_label(self, digit):

        self.frequency.insert(digit)
    def on_pushButton_pressed(self):  # 比如对象obj有信号A，你只需要在同一个类中完成如下形式的函数即可 on_obj_a（）
        '''
        self.conncent.send_date(bytes.fromhex('AA0306000188'))
        time.sleep(0.2)
        self.conncent.send_date(bytes.fromhex('AA030C000188'))
        time.sleep(0.2)
        self.conncent.send_date(bytes.fromhex('AA0304000188'))
        time.sleep(0.2)
        self.conncent.send_date(bytes.fromhex('AA030D000188'))
        time.sleep(0.2)
        self.conncent.send_date(bytes.fromhex('AA0303000188'))
        '''
        self.pic()
        self.timer = QTimer()
        self.timer.timeout.connect(self.pic)
        self.timer.start(10)
    def on_ch_1_pressed(self):
        self.conncent.send_date(bytes.fromhex('AA030D000088'))
    def on_ch_2_pressed(self):
        self.conncent.send_date(bytes.fromhex('AA030D000188'))
    def on_B_scan_pressed(self):  # 比如对象obj有信号A，你只需要在同一个类中完成如下形式的函数即可 on_obj_a（）

        self.conncent.send_date(bytes.fromhex('AA0306000188'))
        time.sleep(0.2)
        self.conncent.send_date(bytes.fromhex('AA030C000188'))
        time.sleep(0.2)
        self.conncent.send_date(bytes.fromhex('AA0304000188'))
        time.sleep(0.2)
        self.conncent.send_date(bytes.fromhex('AA030D000188'))
        time.sleep(0.2)
        self.conncent.send_date(bytes.fromhex('AA0303000188'))
        self.k=0
        self.timer = QTimer()
        self.timer.timeout.connect(self.pic_2)
        self.timer.start(10)
    def on_pushButton_2_pressed(self):  # 比如对象obj有信号A，你只需要在同一个类中完成如下形式的函数即可 on_obj_a（）
        date=self.Datasend.text()
        a=bytes.fromhex(date)
        self.conncent.send_date(a)
        b=str(time.time())+" --- recv --> "+str(a)
        self.UartText.setPlainText(b)
        return print(date)
#滤波按钮逻辑
    def on_pushButton_4_pressed(self):
        if self.fil==0:
            self.fil=1
        else:
            self.fil=0

    def pic(self,):
        data1 = dev.read(0x86, 2048*100, 3000)
        a = np.array(data1)
        a = a[0::2]
        if self.fil:
            a = medfilt(a, kernel_size=5)
        else:
            a=a

        mask = a > 140#触发调节
        # Find the indices of all even numbers
        indices = np.where(mask)[0]
        self.pyqtgraph1.clear()  # 清空里面的内容，否则会发生重复绘图的结果
        self.plt2 = self.pyqtgraph1.addPlot(title='信号波形显示')
        #self.plt2.plot(a, pen = pg.mkPen(color=(85, 255, 255), width=1), name="Green curve")
        self.plt2.plot(a[indices[1]-400:], pen = pg.mkPen(color=(85, 255, 255), width=1), name="Green curve")
        self.plt2.setXRange(0, 3000)
        self.plt2.setYRange(0, 255, padding=0)
        self.plt2.showGrid(x=True, y=True)
        #for i in self.conncent.input_date(0.01):
        #    d.append(i)
        #self.encodedate.setPlainText(str(d[-1]))
#全屏显示测试
    def toggle_fullscreen(self):
        if self.isFullScreen():
            self.showNormal()
        else:
            self.showFullScreen()
            '''
            绘图第二面板测试
    def pic_2(self,):
        a= np.random.rand(1000)
        self.lcdNumber.display(88)
        self.pyqtgraph1_2.clear()  # 清空里面的内容，否则会发生重复绘图的结果
        self.plt2 = self.pyqtgraph1_2.addPlot(title='信号波形显示')
        self.plt2.plot(a, pen = pg.mkPen(color=(85, 255, 255), width=1), name="Green curve")
        #self.plt2.plot(a[indices[1]-400:], pen = pg.mkPen(color=(85, 255, 255), width=1), name="Green curve")
        self.plt2.setXRange(0, 500)
        self.plt2.setYRange(0, 255, padding=0)
        self.plt2.showGrid(x=True, y=True)
        #for i in self.conncent.input_date(0.01):
        #    d.append(i)
        #self.encodedate.setPlainText(str(d[-1]))
        '''
#动态图像绘制
    def pic_2(self,):
        d_2 = []

        data1 = dev.read(0x86, 2048*100, 3000)
        a = np.array(data1)
        a = a[0::2]
        if self.fil:
            a = medfilt(a, kernel_size=5)
        else:
            a=a
        mask = a > 140#触发调节
        indices = np.where(mask)[0]
        for i in self.conncent.input_date(0.2):
            print(i)
            d_2.append(i)
        if abs(d_2[1]-d_2[-1])>30:
            self.k+=1
            self.p = np.vstack((self.p, a[indices[1]-400:indices[1]+6000]))
        self.pyqtgraph1_2.clear()  # 清空里面的内容，否则会发生重复绘图的结果
        self.pyqtgraph1_3.clear()  # 清空里面的内容，否则会发生重复绘图的结果
        self.plt4 = self.pyqtgraph1_3.addPlot(title='信号波形显示')
        self.plt3 = self.pyqtgraph1_2.addPlot()
        img_item = pg.ImageItem(self.p)
        self.plt3.addItem(img_item)
        self.plt3.setRange(xRange=[0, 100], yRange=[0, 2000], padding=0)
        color_map = pg.ColorMap([0, 1], [(0, 0, 255), (255, 0, 0)])
        lut = color_map.getLookupTable(nPts=256)
        img_item.setLookupTable(lut)
        self.plt4.plot(a[indices[1] - 400:], pen=pg.mkPen(color=(85, 255, 255), width=1), name="Green curve")
        self.plt4.setXRange(0, 3000)
        self.plt4.setYRange(0, 255, padding=0)
        self.plt4.showGrid(x=True, y=True)
        self.lcdNumber.display(self.k)
        #self.plt3.setLabel('bottom', 'X Label')
        #self.plt3.setLabel('left', 'Y Label')





if __name__ == "__main__":
    import sys


    app = QApplication(sys.argv)
    ui = MainWindow()
    ui.show()
    sys.exit(app.exec())
