from learner import Learner
import numpy as np

learn = Learner()

i_max = 64

print("running with constant reward=(action[0]-action[1])")
for i in range(i_max+1):
    state = np.random.rand(7, 128, 128)
    action = learn.select_action(state)
    value = learn.evaluate_action(state, action)
    state_new = np.random.rand(7, 128, 128)
    reward = action[0]-action[1]
    learn.update_memory(state, action, reward, state_new, 0 if i==i_max else 1)
    print("update "+str(i)+" of "+str(i_max)+", value = "+str(value)+", action = "+str(action)+", reward = "+str(reward))
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
assert(np.linalg.norm(np.asarray(action)-np.asarray(action2))<0.0001)
assert(np.linalg.norm(np.asarray(value)-np.asarray(value2))<0.0001)

print("Continuing with reward=5*(action[1]-action[0])")
for i in range(i_max+1):
    state = np.random.rand(7, 128, 128)
    action = learn.select_action(state)
    value = learn.evaluate_action(state, action)
    state_new = np.random.rand(7, 128, 128)
    reward = 5*(action[1]-action[0])
    learn.update_memory(state, action, reward, state_new, 0 if i==i_max else 1)
    print("update "+str(i)+" of "+str(i_max)+", value = "+str(value)+", action = "+str(action)+", reward = "+str(reward))
    learn.learn(8)
action2 = learn2.select_action(state, False)
value2 = learn2.evaluate_action(state, action)

assert(np.linalg.norm(np.asarray(value)-np.asarray(value2))>0.0001)
assert(np.linalg.norm(np.asarray(action)-np.asarray(action2))>0.0001)

