%% Copr. (c) 2013-2015, Simple <ljy0922@gmail.com> 

-module(aque_sup). 

-export([ 
         start_link/0, 
         init/1 
        ]). 


start_link() -> 
    supervisor:start_link({local, ?MODULE}, ?MODULE, []). 

init([]) -> 
    {ok, 
        {
            {one_for_one, 10, 10}, 
            [
                {
                    aque_server,
                    {aque_server, start_link, []},
                    transient,
                    1000,
                    worker,
                    [aque_server]
                }
            ]
        }
    }.
