from learner import Learner
import numpy as np

learn = Learner()

for i in range(10):
    state = np.random.rand(6, 128, 128)
    action = learn.select_action(state)
    print("action: "+str(action))
    value = learn.evaluate_action(state, action)
    state_new = np.random.rand(6, 128, 128)
    reward = -1
    learn.update_memory(state, action, reward, state_new)
    print("memory size: "+str(learn.mem.size))
    learn.learn(1)

