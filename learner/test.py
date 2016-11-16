from learner import Learner
import numpy as np

learn = Learner()

i_max = 32

for i in range(i_max+1):
    state = np.random.rand(7, 128, 128)
    action = learn.select_action(state)
    value = learn.evaluate_action(state, action)
    state_new = np.random.rand(7, 128, 128)
    reward = -1
    learn.update_memory(state, action, reward, state_new, 0 if i==i_max else 1)
    print("update "+str(i)+" of "+str(i_max))
    assert(learn.mem.size==i+1)
    learn.learn(8)

state = np.random.rand(7, 128, 128)
action = learn.select_action(state, False)
value = learn.evaluate_action(state, action)
learn.save('test.dat')

learn2 = Learner(loadfile='test.dat')
action2 = learn2.select_action(state, False)
value2 = learn2.evaluate_action(state, action)

print(str(action)+"?="+str(action2)+" "+str(value)+"?="+str(value2))
assert((action==action2) and (value==value2))

