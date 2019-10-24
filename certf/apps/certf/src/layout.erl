-module(layout).
-export([solution/2,content/2,header/1,headers/0]).

links() -> [{"","Home"},{"first","First"},{"second","Second"},{"third","Third"},{"fourth","Fourth"}].
flags() -> [{"first",[hidden_deep_within,only_a_comment_away]},{"second",[certified_awesome]},{"third",[]},{"fourth",[]}].

content(Content,Focus) -> 
    NContent  = [Content,"<br>",validation()],
    content_sol(NContent,Focus).

content_sol(Content,Focus) ->
    ["<html>",headers(),
    "<body>",
     layout:header(Focus),
     Content,
     "</body>",
     "</html>"
    ].

validation() ->     
"<form method=\"post\">
        <input type=\"text\" name=\"flag\" placeholder=\"CerTF{flag}\">
        <button type=\"submit\" class=\"btn btn-primary\">Submit</button>
    </form>".

list_item({{Url,Name}, Focus}) -> 
    case Focus of
        true ->
            ["<li class=\"nav-item active\">",
                 "<a class=\"nav-link\" href=\"/",Url,"\">",Name,"<span class=\"sr-only\">(current)</span></a>",
             "</li>"];
        false -> 
            ["<li class=\"nav-item\">",
                 "<a class=\"nav-link\" href=\"/",Url,"\">",Name,"</a>",
             "</li>"]
    end.

create_links(Focus,Links) ->
    lists:map(fun(Name) -> 
                      Item = set_focus(Name,Focus),
                      list_item(Item)
              end, Links).
    

set_focus({U,Name},Focus) -> 
    case Name == Focus of 
        true -> {{U,Name},true};
        _ -> {{U,Name},false}
    end.
        
                                                           
header(Focus) -> 
    ["<header>",
         "<nav class=\"navbar navbar-expand-md navbar-dark fixed-top bg-dark\">",
         "<a class=\"navbar-brand\" href=\"/\">CerTF</a>",
         "<button class=\"navbar-toggler\" type=\"button\" data-toggle=\"collapse\" data-target=\"#navbarCollapse\" aria-controls=\"navbarCollapse\" aria-expanded=\"false\" aria-label=\"Toggle navigation\">",
             "<span class=\"navbar-toggler-icon\"></span>",
         "</button>",
         "<div class=\"collapse navbar-collapse\" id=\"navbarCollapse\">",
             "<ul class=\"navbar-nav mr-auto\">",
             create_links(Focus,links()),
             "</ul>",
         "</div>",
         "</nav>",
     "</header>"].
headers() ->
    ["<head>",
    "<meta charset=\"utf-8\">",
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, shrink-to-fit=no\">",

    "<link rel=\"stylesheet\" href=\"https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css\" integrity=\"sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T\" crossorigin=\"anonymous\">",
    "<script src=\"https://code.jquery.com/jquery-3.3.1.slim.min.js\" integrity=\"sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo\" crossorigin=\"anonymous\"></script>",
    "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js\" integrity=\"sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1\" crossorigin=\"anonymous\"></script>",
    "<script src=\"https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js\" integrity=\"sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM\" crossorigin=\"anonymous\"></script>",
    "<style>
      .bd-placeholder-img {
        font-size: 1.125rem;
        text-anchor: middle;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
        user-select: none;
      }
    /* Move down content because we have a fixed navbar that is 3.5rem tall */
    body {
      padding-top: 7rem;
    }

      @media (min-width: 768px) {
        .bd-placeholder-img-lg {
          font-size: 3.5rem;
        }
      }
    </style>",
    "</head>"].


bad_flag() ->
    ["<h2> Bad Flag </h2>"].

good_flag() ->
    ["<h2> Success! </h2>","
    <p>
    Congratulations! Correct flag!
    </p>
     "
    ].

solution(Challenge,BinFlag) -> 
    [_,Flag] = string:lexemes(binary_to_list(BinFlag),"{}"),
    {_,Flags} = lists:keyfind(Challenge,1,flags()),
    Result = case lists:member(list_to_atom(Flag),Flags) of 
                 true -> 
                     good_flag();
                 false -> 
                     bad_flag()
             end,
    content_sol(Result,Challenge).
