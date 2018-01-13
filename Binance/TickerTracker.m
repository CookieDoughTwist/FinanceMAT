classdef TickerTracker < handle
    properties
        name;
        quantity;
        price_data;
        
        falling;
        
        window_ns;
        price_averages;
        price_dif_averages;
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
        end
        
        function add(self,q)
            self.quantity = self.quantity + q;
        end
        
        function p = price(self)
            p = self.price_data(end);
        end
        
        function plot(self)
            figure();
            hold on;
            title([self.name ' Prices']);
            xlabel('t');
            ylabel('btc');
            plot(self.price_data);
            for ii = 1:length(self.window_ns)
                plot(self.price_averages{ii});
            end
            legend(['Price';split(num2str(self.window_ns))]);
            
            figure();
            hold on;
            title([self.name ' Der']);
            xlabel('t');
            ylabel('btc');
            for ii = 1:length(self.window_ns)
                plot(self.price_averages{ii});
            end
            legend(split(num2str(self.window_ns)));
        end
        
        function plot_stats(self)
            fig = figure();
            hold on;
%             set(fig,'Color','k');
%             setAxesColor(gca,'w','k');
            title([self.name ' Prices']);
            xlabel('t');
            ylabel('btc');
            p = self.price_data;            
            plot(p,'r');
            plot(movmean(p,[6 0]),'g');
            plot(movmean(p,[60 0]),'b');
            legend({'Price','1min','10min'});
            
            fig = figure();
            hold on;
            title([self.name ' Derivatives']);
            xlabel('t');
            ylabel('btc');
%             d = diff(self.price_data);            
            d = diff(movmean(p,[6 0]));            
%             plot(d,'r');
            plot(d,'r');
            plot(movmean(d,[6 0]),'g');
            plot(movmean(d,[60 0]),'b');
            legend({'Price','1min','10min'});
%             legend({'1min','10min'});

            fig = figure();
            hold on;
            title([self.name ' Derivatives']);
            xlabel('t');
            ylabel('btc');
%             d = diff(self.price_data);            
            dd = diff(movmean(p,[60 0]));            
%             plot(d,'r');
            plot(dd,'r');
            plot(movmean(dd,[6 0]),'g');
            plot(movmean(dd,[60 0]),'b');
            legend({'Price','1min','10min'});
%             legend({'1min','10min'});

            fig = figure();
            hold on;
            title([self.name ' Derivatives']);
            xlabel('t');
            ylabel('btc');
%             d = diff(self.price_data);            
            dd = diff(diff(movmean(p,[6 0])));            
%             plot(d,'r');
            plot(dd,'r');
            plot(movmean(dd,[6 0]),'g');
            plot(movmean(dd,[60 0]),'b');
            legend({'Price','1min','10min'});
%             legend({'1min','10min'});
        end
    end
end

function avg = mean_n(arr,n)
    if n > length(arr)
        avg = mean(arr);
    else
        s_idx = length(arr)-n+1;
        avg = mean(arr(s_idx:end));
    end    
end
