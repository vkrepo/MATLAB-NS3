classdef RngSeedManager < MlWrapper
    % RngSeedManager This object models the functionality of a psuedo random number generator.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_rng_seed_manager.html
    
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
        function SetSeed(seed)
            mexRngSeedManager('SetSeed', seed);
        end
        
        function SetRun(run)
            mexRngSeedManager('SetRun', run);
        end
        
        function objND = GetNextStreamIndex()
            objND = mexRngSeedManager('GetNextStreamIndex');
        end
        
        function objND = GetSeed()
            objND = mexRngSeedManager('GetSeed');
        end
        
        function objND = GetRun()
            objND = mexRngSeedManager('GetRun');
        end
    end
end