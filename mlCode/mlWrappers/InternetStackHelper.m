classdef InternetStackHelper < MlWrapper
    % InternetStackHelper This object aggregates IP/TCP/UDP functionality to nodes.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_internet_stack_helper.html
    
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
            mexInternetStackHelper('delete', obj.cppHandle);
        end
        
        function InstallAll(obj)
            mexInternetStackHelper('InstallAll', obj.get());
        end
        
        function obj = InternetStackHelper(varargin)
            switch(length(varargin))
                case 0
                    obj.cppHandle = mexInternetStackHelper('new');
                case 1
                    obj.cppHandle = mexInternetStackHelper('new', varargin{1}.get());
                otherwise
                    obj.cppHandle = 0;
            end
        end
        
        function Install(obj, varargin)
            % Installs internet stack on the given node/node-container.
            
            switch(length(varargin))
                case 1
                    mexInternetStackHelper('Install', obj.get(), varargin{1}.get());
                otherwise
            end
        end
        
        function SetRoutingHelper(obj, varargin)
            switch(length(varargin))
                case 1
                    mexInternetStackHelper('SetRoutingHelper', obj.get(), varargin{1});
                otherwise
            end
        end
    end
end
