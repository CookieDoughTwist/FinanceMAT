classdef PricePlayer < handle
    
    properties
        data_source;
        idx;
        dirs;
        N;
    end
    
    methods
        function self = PricePlayer(data_source)
            if nargin < 1
                data_source = './PriceData';
            end
            self.data_source = data_source;
            self.idx = 1;     
            self.initialize_data();
        end
        
        function initialize_data(self)
            dir_objs = dir(self.data_source);
            self.dirs = {dir_objs(~[dir_objs.isdir]).name};
            self.N = length(self.dirs);
        end
        
        function [time,data] = poll(self)
            if self.idx > self.N
                time = NaN;
                data = Nan;
                return;
            end
            cur_name = self.dirs{self.idx};
            dot_idx = strfind(cur_name,'.');
            time = str2double(cur_name(1:dot_idx(end)-1));
            cur_file = fullfile(self.data_source,cur_name);
            data = open(cur_file);
            data = data.data;
            self.idx = self.idx+1;
        end
        
        function [time,data] = peek(self)
            [time,data] = self.poll();
            self.idx = self.idx-1;
        end
    end
end

