classdef Trader < handle
    
    properties
        btc;
        unit;
        fee_ratio;
        source;
        trackers;
        idx;
    end
    
    methods
        function self = Trader()
            self.btc = 1.0;
            self.unit = 0.05;
            self.fee_ratio = 0.001;
            self.trackers = containers.Map('KeyType','char','ValueType','any');
            self.idx = 1;
        end
        
        function set_source(self,source)
            self.source = source;
        end
        
        function update(self)
            [cur_time,cur_data] = self.source.poll();
%             local_time = datetime(cur_time,'ConvertFrom','posixtime');
%             local_time.TimeZone = 'Local';
%             
%             fprintf('Current Update Time: %f (%s)\n',...
%                 cur_time,datestr(local_time));
            
            for d = cur_data'
                if ~self.trackers.isKey(d.symbol)
                    continue;
                end
                cur_tracker = self.trackers(d.symbol);
                cur_tracker.update(str2double(d.price));
            end
        end
        
        function compute_indicators(self)
        end
        
        function execute1(self)
            for tracker_cell = self.trackers.values()
                tt = tracker_cell{1};
                sw1 = tt.sliding_average(6);
                sw10 = tt.sliding_average(60);
                sw100 = tt.sliding_average(600);
                sd1 = tt.sliding_derivative(6);
                t_r = .005;
                if tt.price < sw10*(1-t_r)
                    if sd1 > 0
                        self.buy(tt,tt.price,self.unit/tt.price);
                    end
                end
                if tt.price > sw10*(1+t_r)
                    if sd1 < 0
                        self.sell(tt,tt.price,self.unit/tt.price);
                    end
                end
            end
        end
        
        function execute2(self)
            for tracker_cell = self.trackers.values()
                tt = tracker_cell{1};
                if rand > 0.5
                    if rand > 0.5        
                        self.buy(tt,tt.price,self.unit/tt.price);                    
                    else                    
                        self.sell(tt,tt.price,self.unit/tt.price);                    
                    end
                end
            end
        end
        
        function start(self)
%             self.init_all_tickers();
%             self.init_tickers({'XRPBTC','BNBBTC','IOTABTC'});
            self.init_tickers({'XRPBTC'});
            steps = 600;%8640;
            while self.idx < steps                
                self.update();
                fprintf(' Current Value = %f btc\n',self.portfolio_btc_value());
%                 self.print_portfolio();
%                 self.compute_indicators();
                
                self.execute2();
                
                self.idx = self.idx+1;
            end
            self.print_portfolio();
        end
        
        function init_tickers(self,syms)
            for symCell = syms
                sym = symCell{1};
                self.trackers(sym) = TickerTracker(sym);
            end
        end
        
        function init_all_tickers(self)
            [~,cur_data] = self.source.peek();
            for d = cur_data'
                self.trackers(d.symbol) = TickerTracker(d.symbol);
            end
        end
        
        function success = buy(self,tracker,price,quantity)
            cost = price*quantity*(1+self.fee_ratio);
            if cost > self.btc
                success = false;
                return;
            end
            self.btc = self.btc - cost;
            tracker.add(quantity);            
            success = true;
        end
        
        function success = sell(self,tracker,price,quantity)            
            if quantity > tracker.quantity
                success = false;
                return;
            end
            gain = price*quantity*(1-self.fee_ratio);
            self.btc = self.btc + gain;
            tracker.add(-quantity);
            success = true;
        end
        
        function val = portfolio_btc_value(self)
            val = self.btc;
            for tracker_cell = self.trackers.values()
                tt = tracker_cell{1};
                val = val + tt.quantity*tt.price;
            end
        end
        
        function print_portfolio(self)
            fprintf('Portfolio:\n');
            fprintf(' BTC = %f\n',self.btc);
            for tracker_cell = self.trackers.values()
                tt = tracker_cell{1};
                fprintf(' %s = %f (%f)\n',tt.name,tt.price,tt.price*tt.quantity);
            end
        end
    end
end

