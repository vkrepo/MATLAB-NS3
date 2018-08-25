classdef ApplicationContainer < MlWrapper
    % ApplicationContainer This object holds a vector of application objects.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_application_container.html
    
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
            mexApplicationContainer('delete', obj.cppHandle);
        end
        
        function objND = GetN(obj)
            objND = mexApplicationContainer('GetN', obj.get());
        end
        
        function objND = Get(obj, i)
            objND = mexApplicationContainer('Get', obj.get(), i);
        end
        
        function obj = ApplicationContainer(varargin)
            switch(length(varargin))
                case 0
                    obj.cppHandle = mexApplicationContainer('new');
                case 1
                    obj.cppHandle = mexApplicationContainer('new', varargin{1});
                otherwise
                    obj.cppHandle = 0;
            end
        end
        
        function Stop(obj, stop)
            % Stops an application at the specified time. Provide stop-time(in seconds) as a double value.
            
            mexApplicationContainer('Stop', obj.get(), stop);
        end
        
        function Start(obj, start)
            % Starts an application at the specified time. Provide start-time(in seconds) as a double value.
            
            mexApplicationContainer('Start', obj.get(), start);
        end
        
        function Add(obj, varargin)
            switch(length(varargin))
                case 1
                    mexApplicationContainer('Add', obj.get(), varargin{1});
                otherwise
            end
        end
    end
    
    methods (Static)
        function objND = appContCreationFromUint64 (val)
            % MATLAB wrapper around c++ ApplicationConatiner object.
            
            objND = ApplicationContainer(0, 0);
            objND.cppHandle = val;
        end
    end
end