import numpy as np
from inputFormat import *

class replay_memory:
    def __init__(self, capacity):
        self.capacity = capacity
        self.size = 0
        self.index = 0
        self.full = False
        self.state1_memory = np.zeros(np.concatenate(([capacity], input_shape)), dtype=bool)
        self.action_memory = np.zeros(capacity, dtype=np.uint8)
        self.reward_memory = np.zeros(capacity, dtype=bool)
        self.state2_memory = np.zeros(np.concatenate(([capacity], input_shape)), dtype=bool)

    def add_entry(self, state1, action, reward, state2):
        self.state1_memory[self.index, :, :] = state1
        self.state2_memory[self.index, :, :] = state2
        self.action_memory[self.index] = action
        self.reward_memory[self.index] = reward
        self.index += 1
        if(self.index>=self.capacity):
            self.full = True
            self.index = 0
        if not self.full:
            self.size += 1

    def sample_batch(self, size):
        batch = np.random.choice(np.arange(0,self.size), size=size)
        states1 = self.state1_memory[batch]
        states2 = self.state2_memory[batch]
        actions = self.action_memory[batch]
        rewards = self.reward_memory[batch]
        return (states1, actions, rewards, states2)