classdef EventId < MlWrapper
    % EventId This object acts as an identifier for simulation events.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_event_id.html
    
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
            mexEventId('delete', obj.cppHandle);
        end
        
        function obj = EventId(varargin)
            switch(length(varargin))
                case 0
                    obj.cppHandle = mexEventId('new');
                case 4
                    obj.cppHandle = mexEventId('new', varargin{1}.get(), varargin{2}, varargin{3}, varargin{4});
                otherwise
                    obj.cppHandle = 0;
            end
        end
        
        function objND = IsRunning(obj)
            objND = mexEventId('IsRunning', obj.get());
        end
        
        function objND = GetContext(obj)
            objND = mexEventId('GetContext', obj.get());
        end
        
        function Cancel(obj)
            mexEventId('Cancel', obj.get());
        end
        
        function objND = GetUid(obj)
            objND = mexEventId('GetUid', obj.get());
        end
        
        function objND = IsExpired(obj)
            objND = mexEventId('IsExpired', obj.get());
        end
        
        function objND = GetTs(obj)
            objND = mexEventId('GetTs', obj.get());
        end
    end
    
    methods (Static)
        function objND = eventIdCreationFromUint64 (val)
            % MATLAB wrapper around c++ EventId object.
            
            objND = EventId(0, 0, 0, 0, 0);
            objND.cppHandle = val;
        end
    end
end