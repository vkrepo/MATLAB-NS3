classdef NodeContainer < MlWrapper
    % NodeContainer This object holds a set of node objects.
    % When NS3 wants to install something on a group of nodes, it just iterates on this container to get reference of all nodes.
    % More Details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_node_container.html
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties ( Access = private, Hidden = true)
        cppHandle
    end
    
    methods
        function set(obj, val)
            obj.cppHandle = val;
        end
        
        function val = get(obj)
            val = obj.cppHandle;
        end
        
        function delete(obj)
            mexNodeContainer('delete', obj.cppHandle);
        end
        
        function Create(obj, varargin)
            switch(length(varargin))
                case 1
                    assert(((varargin{1} > 0) & varargin{1} <= 10000),...
                        'Number of nodes must be between 1 and 10000');
                    mexNodeContainer('Create', obj.get(), varargin{1});
                case 2
                    assert(((varargin{1} > 0) & varargin{1} <= 10000),...
                        'Number of nodes must be between 1 and 10000');
                    mexNodeContainer('Create', obj.get(), varargin{1}, varargin{2});
                otherwise
            end
        end
        
        function obj = NodeContainer(varargin)
            switch(length(varargin))
                case 0
                    obj.cppHandle = mexNodeContainer('new');
                case 1
                    obj.cppHandle = mexNodeContainer('new', varargin{1});
                case 2
                    obj.cppHandle = mexNodeContainer('new', varargin{1}.get(), varargin{2}.get());
                case 3
                    obj.cppHandle = mexNodeContainer('new', varargin{1}.get(), varargin{2}.get(), varargin{3}.get());
                case 4
                    obj.cppHandle = mexNodeContainer('new', varargin{1}.get(), varargin{2}.get(), varargin{3}.get(), varargin{4}.get());
                case 5
                    obj.cppHandle = mexNodeContainer('new', varargin{1}.get(), varargin{2}.get(), varargin{3}.get(), varargin{4}.get(), varargin{5}.get());
                otherwise
                    obj.cppHandle = 0;
            end
        end
        
        function Add(obj, varargin)
            switch(length(varargin))
                case 1
                    mexNodeContainer('Add', obj.get(), varargin{1});
                otherwise
            end
        end
        
        function objND = GetN(obj)
            objND = mexNodeContainer('GetN', obj.get());
        end
        
        function objND = Get(obj, i)
            objND = mexNodeContainer('Get', obj.get(), i);
            objND = Node.nodeCreationFromUint64(objND);
        end
    end
end