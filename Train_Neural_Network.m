if count(py.sys.path,'learner') == 0
    insert(py.sys.path,int32(0),'learner');
end

import py.learner.Learner

learn = py.learner.Learner();