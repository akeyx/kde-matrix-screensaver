import subprocess
import time
import sys
import os

proc = subprocess.Popen(["qml-qt6", "run_standalone.qml"])
time.sleep(4)

# Grab screenshot
os.system("import -window root final_test.png")
proc.terminate()
