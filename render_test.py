import sys
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtCore import QTimer

app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
engine.load('run_standalone.qml')

if not engine.rootObjects():
    sys.exit(-1)

window = engine.rootObjects()[0]

def grab():
    img = window.grabWindow()
    img.save('test_render.png')
    app.quit()

QTimer.singleShot(2000, grab)
sys.exit(app.exec())
