classdef TickerTracker < handle
    properties
        name;
        quantity;
        price_data;        
        
        falling;
        
        window_ns;
        price_averages;
        price_dif_averages;
        
        price_1st_dif_averages;
        
    end
    
    methods
        function self = TickerTracker(name,window_ns)
            self.name = name;
            self.quantity = 0.0;
            self.falling = true;
            
            if nargin < 2
                window_ns = [6 60 360]; % 1min 10min 1hr
            end
            
            self.window_ns = window_ns;
            self.price_averages = {};
            self.price_dif_averages = {};
            for ii = 1:length(self.window_ns)
                self.price_averages{ii} = [];
                self.price_dif_averages{ii} = [];
                self.price_1st_dif_averages{ii} = [];
            end
        end

        function update(self,in_data)
            self.price_data(end+1) = in_data;
            price_dif = diff(self.price_data);            
            for ii = 1:length(self.window_ns)
                n = self.window_ns(ii);
                self.price_averages{ii}(end+1) = mean_n(self.price_data,n);
                self.price_dif_averages{ii}(end+1) = mean_n(price_dif,n);
            end
            price_1st_dif = diff(self.price_averages{1});
            for ii = 1:length(self.window_ns)
                n = self.window_ns(ii);
                self.price_1st_dif_averages{ii}(end+1) = mean_n(price_1st_dif,n);
            end
        end
        
        function add(self,q)
            self.quantity = self.quantity + q;
        end
        
        function p = price(self)
            p = self.price_data(end);
        end
        
        function plot(self)
%             figure();
%             title([self.name ' Price']);
%             xlabel('Intervals (10s)');
%             ylabel('BTC');
%             plot(self.price_data);
            self.plot_averages(self.price_averages,'Price Averages');
            self.plot_averages(self.price_dif_averages,'Dif Averages');
            self.plot_averages(self.price_1st_dif_averages,'First window dif averages');
        end
        
        function plot_averages(self,avg_cells,title_str)
            figure();
            hold on;
            title([self.name ' ' title_str]);
            xlabel('Intervals (10s)');
            ylabel('BTC');
            plot(self.price_data);
            for ii = 1:length(self.window_ns)
                plot(avg_cells{ii});
            end
            legend(['Price'; split(num2str(self.window_ns))]);
        end
    end
end

function avg = mean_n(arr,n)
    if n > length(arr)
%         avg = mean(arr);
        avg = NaN;
    else
        s_idx = length(arr)-n+1;
        avg = mean(arr(s_idx:end));
    end    
end
