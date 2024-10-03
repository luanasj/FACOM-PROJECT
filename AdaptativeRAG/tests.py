systemActive = True

def systemActivation(state):
    global systemActive
    systemActive = not systemActive


systemActivation(systemActive)
print(systemActive)
systemActivation(systemActive)
print(systemActive)
systemActivation(systemActive)
print(systemActive)


