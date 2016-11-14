from learner import Learner
import numpy as np

learn = Learner()

state = np.random.rand(6, 128, 128)
action = learn.select_action(state)
value = learn.evaluate_action(state, action)
state_new = np.random.rand(6, 128, 128)
reward = -1
learn.update_memory(state, action, reward, state_new)
learn.learn(1)

