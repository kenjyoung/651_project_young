import theano
from theano import tensor as T
import numpy as np
import lasagne
from replay_memory import replay_memory
import cPickle

input_shape = (7, 128, 128)
num_params = 3
class Learner:
    def __init__(self, loadfile = None, gamma = 1, alpha = 0.001, rho = 0.9, epsilon = 1e-6):
        self.mem = replay_memory(5000, input_shape, num_params)
        self.gamma = gamma

        #Create Input Variables
        state = T.tensor3('state')
        action = T.fvector('action')
        state_batch = T.tensor4('state_batch')
        action_batch = T.matrix('action_batch')
        expanded_action = T.transpose(T.tile(T.transpose(action_batch), (128,128,1,1)))
        state_action = T.concatenate((state_batch, expanded_action), axis=1)
        Q_targets = T.fvector('Q_target')

        if(loadfile != None):
            with file(loadfile, 'rb') as f:
                params = cPickle.load(f)
            p_params = params["p"]
            q_params = params["q"]

        #Build Policy Network
        p_in = lasagne.layers.InputLayer(
            shape=(None, input_shape[0], input_shape[1], input_shape[2]),
            input_var = state_batch
        )

        p_conv1 = lasagne.layers.Conv2DLayer(
            p_in,
            num_filters=32, filter_size=(5,5),
            nonlinearity = lasagne.nonlinearities.rectify,
            stride = 1,
            W=lasagne.init.HeNormal(gain='relu')
        )

        p_conv2 = lasagne.layers.Conv2DLayer(
            p_conv1,
            num_filters=32, filter_size=(3,3),
            nonlinearity = lasagne.nonlinearities.rectify,
            stride = 2,
            W=lasagne.init.HeNormal(gain='relu')
        )

        p_conv3 = lasagne.layers.Conv2DLayer(
            p_conv2,
            num_filters=32, filter_size=(3,3),
            nonlinearity = lasagne.nonlinearities.rectify,
            stride = 2,
            W=lasagne.init.HeNormal(gain='relu')
        )

        p_conv4 = lasagne.layers.Conv2DLayer(
            p_conv3,
            num_filters=32, filter_size=(3,3),
            nonlinearity = lasagne.nonlinearities.rectify,
            stride = 1,
            W=lasagne.init.HeNormal(gain='relu')
        )

        p_conv5 = lasagne.layers.Conv2DLayer(
            p_conv4,
            num_filters=32, filter_size=(3,3),
            nonlinearity = lasagne.nonlinearities.rectify,
            stride = 1,
            W=lasagne.init.HeNormal(gain='relu')
        )

        p_hidden = lasagne.layers.DenseLayer(
            p_conv5, num_units=64,
            nonlinearity=lasagne.nonlinearities.rectify,
            W=lasagne.init.HeNormal(gain='relu')
        )

        self.p_output = lasagne.layers.DenseLayer(
            p_hidden,
            num_units=num_params,
            #purely linear layer
            nonlinearity= lasagne.nonlinearities.sigmoid,
            W=lasagne.init.HeNormal(gain=1.0)
        )

        if(loadfile != None):
            lasagne.layers.set_all_param_values(self.p_output, p_params)

        policy_output = lasagne.layers.get_output(self.p_output)

        #Build Q Network
        q_in = lasagne.layers.InputLayer(
            shape=(None, input_shape[0]+num_params, input_shape[1], input_shape[2]),
            input_var = state_action
        )

        q_conv1 = lasagne.layers.Conv2DLayer(
            q_in,
            num_filters=32, filter_size=(5,5),
            nonlinearity = lasagne.nonlinearities.rectify,
            stride = 1,
            W=lasagne.init.HeNormal(gain='relu')
        )

        q_conv2 = lasagne.layers.Conv2DLayer(
            q_conv1,
            num_filters=32, filter_size=(3,3),
            nonlinearity = lasagne.nonlinearities.rectify,
            stride = 2,
            W=lasagne.init.HeNormal(gain='relu')
        )

        q_conv3 = lasagne.layers.Conv2DLayer(
            q_conv2,
            num_filters=32, filter_size=(3,3),
            nonlinearity = lasagne.nonlinearities.rectify,
            stride = 2,
            W=lasagne.init.HeNormal(gain='relu')
        )

        q_conv4 = lasagne.layers.Conv2DLayer(
            q_conv3,
            num_filters=32, filter_size=(3,3),
            nonlinearity = lasagne.nonlinearities.rectify,
            stride = 1,
            W=lasagne.init.HeNormal(gain='relu')
        )

        q_conv5 = lasagne.layers.Conv2DLayer(
            q_conv4,
            num_filters=32, filter_size=(3,3),
            nonlinearity = lasagne.nonlinearities.rectify,
            stride = 1,
            W=lasagne.init.HeNormal(gain='relu')
        )

        q_hidden = lasagne.layers.DenseLayer(
            q_conv5, num_units=64,
            nonlinearity=lasagne.nonlinearities.rectify,
            W=lasagne.init.HeNormal(gain='relu')
        )

        self.q_output = lasagne.layers.DenseLayer(
            q_hidden,
            num_units=1,
            #purely linear layer
            nonlinearity= None,
            W=lasagne.init.HeNormal(gain=1.0)
        )

        if(loadfile != None):
            lasagne.layers.set_all_param_values(self.q_output, q_params)

        evaluation = lasagne.layers.get_output(self.q_output)

        #Build functions
        self._select_action = theano.function(
            [state],
            givens = {state_batch : state.dimshuffle('x',0,1,2)},
            outputs = policy_output.flatten()
        )

        self._evaluate_action = theano.function(
            [state, action],
            givens = {state_batch : state.dimshuffle('x',0,1,2), action_batch : action.dimshuffle('x',0)},
            outputs = evaluation.flatten()
        )

        self._select_actions = theano.function(
            [state_batch],
            outputs = policy_output
        )

        self._evaluate_actions = theano.function(
            [state_batch, action_batch],
            outputs = evaluation.flatten()
        )

        Q_loss = lasagne.objectives.squared_error(evaluation.flatten(), Q_targets)
        agg_Q_loss = lasagne.objectives.aggregate(Q_loss, mode='mean')
        Q_params = lasagne.layers.get_all_params(self.q_output)
        Q_updates = lasagne.updates.rmsprop(agg_Q_loss, Q_params, alpha, rho, epsilon)
        self._update_Q = theano.function(
            [state_batch, action_batch, Q_targets],
            updates = Q_updates
        )


        P_params = lasagne.layers.get_all_params(self.p_output)

        agg_evaluation = lasagne.objectives.aggregate(evaluation.flatten(), mode='mean')
        Q_grads = T.grad(agg_evaluation, action_batch)
        V_grads = T.Lop(policy_output, P_params, Q_grads)
        neg_V_grads=[-x for x in V_grads]
        #negate gradients so that rmsprop preforms gradient ascent on action values
        P_updates = lasagne.updates.rmsprop(neg_V_grads, P_params, alpha, rho, epsilon)
        self._update_P = theano.function(
            [state_batch],
            givens = {action_batch : policy_output},
            updates = P_updates
        )


    def select_action(self, state, explore=True):
        state = np.asarray(state, dtype=theano.config.floatX).reshape(input_shape)
        return list(np.clip(self._select_action(state)+[(np.random.normal(scale=0.1) if explore else 0) for i in range(num_params)], 0, 1))

    def evaluate_action(self, state, action):
        state = np.asarray(state, dtype = theano.config.floatX).reshape(input_shape)
        action = np.asarray(action, dtype = theano.config.floatX)
        return list(self._evaluate_action(state, action))

    def update_memory(self, state1, action, reward, state2, terminal):
        state1 = np.asarray(state1, dtype = theano.config.floatX).reshape(input_shape)
        state2 = np.asarray(state2, dtype = theano.config.floatX).reshape(input_shape)
        action = np.asarray(action, dtype = theano.config.floatX)
        self.mem.add_entry(state1, action, reward, state2, terminal)

    def learn(self, batch_size):
        #do nothing if we don't yet have enough entries in memory for a full batch
        if(self.mem.size < batch_size):
            return
        states1, actions, rewards, states2, terminals = self.mem.sample_batch(batch_size)
        targets = np.zeros(rewards.size).astype(theano.config.floatX)
        targets[terminals==0] = rewards[terminals==0]+self.gamma*self._evaluate_actions(states2, self._select_actions(states2))[terminals==0]
        targets[terminals==1] = rewards[terminals==1]

        self._update_Q(states1, actions, targets)
        self._update_P(states1)

    def save(self, savefile = 'learner.save'):
        p_params = lasagne.layers.get_all_param_values(self.p_output)
        q_params = lasagne.layers.get_all_param_values(self.q_output)
        params = {'q':q_params, 'p':p_params}
        with file(savefile, 'wb') as f:
            cPickle.dump(params, f, protocol=cPickle.HIGHEST_PROTOCOL)


