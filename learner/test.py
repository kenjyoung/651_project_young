from learner import Learner
import numpy as np

learn = Learner()

for i in range(128):
    state = np.random.rand(7, 128, 128)
    action = learn.select_action(state)
    value = learn.evaluate_action(state, action)
    state_new = np.random.rand(7, 128, 128)
    reward = -1
    learn.update_memory(state, action, reward, state_new)
    print("update "+str(i)+" of 128")
    assert(learn.mem.size==i+1)
    learn.learn(8)

state = np.random.rand(7, 128, 128)
action = learn.select_action(state, False)
value = learn.evaluate_action(state, action)
learn.save('test.dat')

learn2 = Learner(loadfile='test.dat')
action2 = learn2.select_action(state, False)
value2 = learn2.evaluate_action(state, action)

assert((action==action2) and (value==value2))

