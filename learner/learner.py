import theano
from theano import tensor as T
import numpy as np
import lasagne
from replay_memory import replay_memory

input_shape = (3, 128, 128)
num_params = 3
#TODO: finish fixing actions to be correct size
class Learner:
    def __init__(self, gamma = 1, alpha = 0.001, rho = 0.9, epsilon = 1e-6):
        self.mem = replay_memory(1000, input_shape)
        self.gamma = gamma

        #Create Input Variables
        state = T.tensor3('state')
        action = T.fvector('action')
        state_batch = T.tensor4('state_batch')
        action_batch = T.matrix('action_batch')
        expanded_action = action_batch*T.ones((action_batch.shape[0], action_batch.shape[1], input_shape[1], input_shape[2]))
        state_action = T.concatenate((state_batch, expanded_action), axis=1)
        Q_targets = T.fvector('Q_target')

        #Build Policy Network
        p_in = lasagne.layers.InputLayer(
            shape=(None, input_shape[0], input_shape[1], input_shape[2]),
            input_var = state_batch
        )

        p_conv1 = lasagne.layers.Conv2DLayer(
            p_in,
            num_filters=32, filter_size=(5,5),
            nonlinearity = lasagne.nonlinearities.rectify,
            W=lasagne.init.HeNormal(gain='relu')
        )

        p_conv2 = lasagne.layers.Conv2DLayer(
            p_conv1,
            num_filters=16, filter_size=(3,3),
            nonlinearity = lasagne.nonlinearities.rectify,
            stride = 2,
            W=lasagne.init.HeNormal(gain='relu')
        )

        p_conv3 = lasagne.layers.Conv2DLayer(
            p_conv2,
            num_filters=16, filter_size=(3,3),
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
            nonlinearity= lasagne.nonlinearities.rectify,
            W=lasagne.init.HeNormal(gain=1.0)
        )

        policy_output = lasagne.layers.get_output(p_output)

        #Build Q Network
        q_in = lasagne.layers.InputLayer(
            shape=(None, input_shape[0]+num_params, input_shape[1], input_shape[2]),
            input_var = state_action
        )
        q_conv1 = lasagne.layers.Conv2DLayer(
            q_in,
            num_filters=32, filter_size=(5,5),
            nonlinearity = lasagne.nonlinearities.rectify,
            W=lasagne.init.HeNormal(gain='relu')
        )

        q_conv2 = lasagne.layers.Conv2DLayer(
            q_conv1,
            num_filters=16, filter_size=(3,3),
            nonlinearity = lasagne.nonlinearities.rectify,
            stride = 2,
            W=lasagne.init.HeNormal(gain='relu')
        )

        q_conv3 = lasagne.layers.Conv2DLayer(
            q_conv2,
            num_filters=16, filter_size=(3,3),
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

        evaluation = lasagne.layers.get_output(q_output)

        #Build functions
        self._select_action = theano.function(
            [state],
            givens = {state_batch : state.dimshuffle('x',0,1,2)},
            outputs = policy_output
        )

        self._evaluate_action = theano.function(
            [state, action],
            givens = {state_batch : state.dimshuffle('x',0,1,2), action_batch : action.dimshuffle('x',0)},
            outputs = evaluation
        )

        Q_loss = lasagne.objectives.squared_error(evaluation, Q_targets)
        Q_loss = lasagne.objectives.aggregate(Q_loss, mode='mean')
        Q_params = lasagne.layers.get_all_params(q_output)
        Q_updates = lasagne.updates.rmsprop(Q_loss, Q_params, alpha, rho, epsilon)
        self._update_Q = theano.function(
            [state_batch, action_batch, Q_targets],
            updates = Q_updates
        )


        Q_grad = T.jacobian(evaluation.flatten(), action_batch)
        P_params = lasagne.layers.get_all_params(p_output)
        P_grad = T.jacobian(policy_output.flatten(), P_params)
        V_grads = T.dot(Q_grad, P_grad)
        P_updates = lasagne.updates.rmsprop(V_grads, P_params, alpha, rho, epsilon)
        self._update_P = theano.function(
            [state_batch],
            givens = {action_batch : policy_output},
            updates = P_updates
        )


    def select_action(self, state, explore=True):
        return self._select_action(state)*([1+(np.random.normal() if explore else 0) for i in range(num_params)])

    def evaluate_action(self, state, action):
        return self._evaluate_action(state, action)

    def update_memory(self, state1, action, reward, state2):
        self.mem.add_entry(state1, action, reward, state2)

    def learn(self, batch_size):
        states1, actions, rewards, states2 = self.mem.sample_batch(batch_size)
        targets = rewards+self.gamma*self._evaluate_action(states2, self.select_action(states2))
        self._update_Q(states1, actions, targets)
        self._update_P(states1)


