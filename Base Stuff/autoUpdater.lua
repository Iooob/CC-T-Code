print(2)
fs.delete("autoUpdater.lua")
shell.run("wget https://raw.githubusercontent.com/Iooob/CC-T-Code/main/Base%20Stuff/autoUpdater.lua autoUpdater.lua")
os.sleep(1)
shell.run("autoUpdater")