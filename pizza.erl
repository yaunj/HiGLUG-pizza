% Erlang version, author: Trygve Laugstøl
% erl pizza.erl
% c(pizza).
% pizza:run(8).  % Order for 8 people.
-module(pizza).
 
-export([run/0, run/1]).
 
-import(random,[seed/0,uniform/1]).
-import(lists,[duplicate/2, nth/2]).
 
-define(PRIZE_MAX, 1200).
-define(EL_CHEAPO, 119).
-define(PIZZA_PER_HEAD, 0.4).
 
-define(DEFAULT_HEADS, 5).
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% API
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
run() ->
    run(?DEFAULT_HEADS).
 
run(Heads) when is_integer(Heads) ->
    NumOfPizzas = number_of_pizzas(Heads),
    Choices = calculate_choices(menu(), []),
    Selection = select_pizzas(NumOfPizzas, Choices, []),
    print_selection(Selection).
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Private
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
number_of_pizzas(Heads) ->
    C = Heads * ?PIZZA_PER_HEAD,
    T = erlang:trunc(C),
    case (C - T) of
        Neg when Neg < 0 -> T - 1;
        Pos when Pos > 0 -> T + 1;
        _ -> T
    end.
 
menu() ->
    [
        {"Pappas spesial", 4, 159},
        {"Texas", 3, 149},
        {"Blue Hawai", 7, 149},
        {"Floriad", 4, 149},
        {"Buffalo", 4, 149},
        {"Chicken", 4, 149},
        {"New York", 0, 149},
        {"Las Vegas", 6, 149},
        {"Vegetarianer", 0, 149},
        {"FILADELFIA", 4, 149},
        {"Hot Chicago", 7, 149},
        {"Hot Express", 5, 149},
        {"Kebab pizza spesial", 3, 169},
        {"Egenkomponert; Pepperoni, Biff, Bacon, Skinke, l0k", 9, 159},
        {"Egenkomponert; Biff, Pepperoni, Bacon, Skinke, Tacokj0tt", 9, 159}
    ].
 
calculate_choices([Pizza | Menu], Choices) ->
    Weight = element(2, Pizza),
    X = duplicate(Weight, Pizza),
    calculate_choices(Menu, X ++ Choices);
 
calculate_choices([], Choices) ->
    Choices.
 
select_pizzas(0, _, Selection) ->
    Selection;
 
select_pizzas(NumOfPizzas, Choices, Selection) when NumOfPizzas > 0 ->
    Selected = nth(uniform(length(Choices)), Choices),
    select_pizzas(NumOfPizzas - 1, Choices, [Selected|Selection] ).
 
print_pizzas([], _, Cost) ->
    Cost;
 
print_pizzas([Pizza | Selection], Index, TotalCost) ->
    Cost = element(3, Pizza),
    io:format("#~2..0w ~-30s ~5w~n", [Index, element(1, Pizza), Cost]),
    print_pizzas(Selection, Index + 1, TotalCost + Cost).
 
print_selection(Selection) ->
    io:format("========================================~n"),
    Cost = print_pizzas(Selection, 0, 0),
    io:format("========================================~n"),
    io:format("Count: ~2w, Cost:                   ~5w~n", [length(Selection), Cost]).
