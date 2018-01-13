function record_klines(tickers,interval)
    if nargin < 2
        % interval = 29940000/1000;
        interval = 29900000/1000;
    end
    if nargin < 1
        tickers = ...
            {'BTCUSDT','XRPBTC','IOTABTC','DASHBTC','XMRBTC',...
            'XLMBTC','TRXBTC','BNBBTC','ADABTC','BATBTC','ETHBTC'};
    end
    import matlab.net.*
    import matlab.net.http.*
    r = RequestMessage;
    uri_str = 'https://api.binance.com/api/v1/klines?symbol=%s&interval=1m';
    while true
        nonsleep = tic;
        success = true;
        current_posix = num2str(posixtime(datetime));
        fprintf('Current time: %s\n',current_posix);
        for ticker_cell = tickers
            ticker = ticker_cell{1};
            fprintf(' Loading %s\n',ticker);
            cur_uri = URI(sprintf(uri_str,ticker));
            try
                resp = send(r,cur_uri);
            catch
                resp = [];
                disp('Send failed!');
            end
            if isempty(resp)
                success = false;
                break;
            end
            data = resp.Body.Data; %#ok<NASGU>
            
            filename = ['./KlineData/' ticker '/' current_posix '.mat'];
            save(filename,'data');
        end
        if ~success
            continue;
        end
        execution_time = toc(nonsleep);
        pause_time = max(interval-execution_time,0);
        pause(pause_time);
    end
end

