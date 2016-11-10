import theano
from theano import tensor as T
import numpy as np
import lasagne
import replay_memory

input_shape = (3, 120, 160)
num_params = 3
class learner:
    def __init__(self, gamma = 1, alpha = 0.001, rho = 0.9, epsilon = 1e-6):
        self.mem = replay_memory(1000)
        self.gamma = gamma

        #Build Policy Network
        p_in = lasagne.layers.InputLayer(
            shape=(None, input_shape[0], input_shape[1], input_shape[2])
        )

        p_conv1 = lasagne.layers.Conv2DLayer(
            p_in,
            num_filters=16, filter_size=(5,5),
            nonlinearity = lasagne.nonlinearities.rectify,
            W=lasagne.init.HeNormal(gain='relu')
        )

        p_conv2 = lasagne.layers.Conv2DLayer(
            p_conv1,
            num_filters=8, filter_size=(3,3),
            nonlinearity = lasagne.nonlinearities.rectify,
            stride = 2,
            W=lasagne.init.HeNormal(gain='relu')
        )

        p_conv3 = lasagne.layers.Conv2DLayer(
            p_conv2,
            num_filters=8, filter_size=(3,3),
            nonlinearity = lasagne.nonlinearities.rectify,
            stride = 2,
            W=lasagne.init.HeNormal(gain='relu')
        )

        p_hidden = lasagne.layers.DenseLayer(
            p_conv3, num_units=64,
            nonlinearity=lasagne.nonlinearities.rectify,
            W=lasagne.init.HeNormal(gain='relu')
        )

        p_output = lasagne.layers.DenseLayer(
            p_hidden,
            num_units=num_params,
            #purely linear layer
            nonlinearity= None,
            W=lasagne.init.HeNormal(gain=1.0)
        )

        action = lasagne.layers.get_output(p_output, p_in.input_var)

        #Build Q Network
        q_in = lasagne.layers.InputLayer(
            shape=(None, input_shape[0]+num_params, input_shape[1], input_shape[2])
        )
        q_conv1 = lasagne.layers.Conv2DLayer(
            q_in,
            num_filters=16, filter_size=(5,5),
            nonlinearity = lasagne.nonlinearities.rectify,
            W=lasagne.init.HeNormal(gain='relu')
        )

        q_conv2 = lasagne.layers.Conv2DLayer(
            q_conv1,
            num_filters=8, filter_size=(3,3),
            nonlinearity = lasagne.nonlinearities.rectify,
            stride = 2,
            W=lasagne.init.HeNormal(gain='relu')
        )

        q_conv3 = lasagne.layers.Conv2DLayer(
            q_conv2,
            num_filters=8, filter_size=(3,3),
            nonlinearity = lasagne.nonlinearities.rectify,
            stride = 2,
            W=lasagne.init.HeNormal(gain='relu')
        )

        q_hidden = lasagne.layers.DenseLayer(
            q_conv3, num_units=64,
            nonlinearity=lasagne.nonlinearities.rectify,
            W=lasagne.init.HeNormal(gain='relu')
        )

        q_output = lasagne.layers.DenseLayer(
            q_hidden,
            num_units=1,
            #purely linear layer
            nonlinearity= None,
            W=lasagne.init.HeNormal(gain=1.0)
        )

        evaluation = lasagne.layers.get_output(q_output, q_in.input_var)

        #Build functions
        self.select_action = theano.function(
            [p_in.input_var],
            action
            )
        self.evaluate_action = theano.function(
            [state, action],
            givens = {q_in.input_var: T.concatenate(state, action, axis=1)},
            evaluation
            )

        Q_targets = T.fvector('target')
        Q_loss = lasagne.objectives.squared_error(action, Q_targets)
        Q_loss = lasagne.objectives.aggregate(Q_loss, mode='mean')
        Q_params = lasagne.layers.get_all_params(q_output)
        Q_updates = lasagne.updates.rmsprop(Q_loss, Q_params, alpha, rho, epsilon)
        self.update_Q = theano.function(
            [state, action, Q_targets],
            givens = {q_in.input_var: T.concatenate(state, action, axis=1)},
            updates = Q_updates
            )

        state_batch = T.tensor4('state_batch')
        V = self.evaluate_action(state_batch, self.select_action(state_batch))
        P_params = lasagne.layers.get_all_params(p_output)
        V_grads = T.grad(V, P_params)
        P_updates = lasagne.updates.rmsprop(V_grads, P_params, alpha, rho, epsilon)
        self.update_P = theano.function(
            [p_in.input_var],
            updates = P_updates
            )


    def select_action(self, state, explore=True):
        return self.select_action(state)*(1+(np.random.normal() if explore else 0))

    def evaluate_action(self, state, action):
        return self.evaluate_action(state, action)

    def update_memory(self, state1, action, reward, state2):
        self.mem.add_entry(state1, action, reward, state2)

    def learn(self, batch_size):
        states1, actions, rewards, states2 = self.mem.sample_batch(batch_size)
        targets = rewards+self.gamma*self.evaluate_action(state2, self.select_action(state2))
        self.update_Q(states1, actions, targets)
        self.update_P(states1)


