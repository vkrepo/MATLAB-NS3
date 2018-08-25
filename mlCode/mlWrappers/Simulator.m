classdef Simulator < MlWrapper
    % Simulator This object is used to create and control the scheduling of simulation events.
    % Events start processing at their scheduled times, once run method of this object is called.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_simulator.html
    
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
    end
    
    methods (Static)
        function Run()
            mexSimulator('Run');
        end
        
        function objND = Schedule(func_handle, periodicity, context)
            % Schedules an event to callback MATLAB function handle(func_handle) after the specified time (periodicity) with data as structure (context).
            
            objND = mexSimulator('Schedule', func_handle, periodicity, context);
            objND = EventId.eventIdCreationFromUint64(objND);
        end
        
        function Stop(stoptime)
            % Stops the simulation at the specified stop-time(in seconds) provided as double value.
            
            mexSimulator('Stop',stoptime);
        end
        
        function objND = GetContext()
            objND = mexSimulator('GetContext');
        end
        
        function Cancel(id)
            mexSimulator('Cancel', id.get());
        end
        
        function Destroy()
            mexSimulator('Destroy');
        end
        
        function objND = Now()
            objND = mexSimulator('Now');
        end
    end
end