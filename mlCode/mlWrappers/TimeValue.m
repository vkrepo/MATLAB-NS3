classdef TimeValue < MlWrapper
    %TimeValue This object holds a time. This can be used for setting time-type of attributes to NS3 models.
    %More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_time_value.html
    
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
            mexTimeValue('delete', obj.cppHandle);
        end
        
        function Set(obj, value)
            mexTimeValue('Set', obj.get(), value.get());
        end
        
        function obj = TimeValue(varargin)
            switch(length(varargin))
                case 0
                    obj.cppHandle = mexTimeValue('new');
                case 1
                    obj.cppHandle = mexTimeValue('new', varargin{1});
                otherwise
                    obj.cppHandle = 0;
            end
        end
    end
end
