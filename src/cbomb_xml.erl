-module(cbomb_xml).

-include_lib("eunit/include/eunit.hrl").

-export([get_response/1, get_tag/1, add_user/3, logged_on/2, disconnect_user/1]).

-record(tag, {name, attributes, children}).

get_tag(Packet) ->
  {Element, _} = xmerl_scan:string(Packet, [{space, normalize}]),
  [Clean] = xmerl_lib:remove_whitespace([Element]),
  Simple = xmerl_lib:simplify_element(Clean),
  #tag{name=element(1, Simple), attributes=element(2, Simple), children=element(3, Simple)}.
    
%handle(Msg, State) when Msg==#msg{to=void, no=3} ->
get_response(#tag{name='policy-file-request'}) ->
    "<?xml version=\"1.0\"?>"
    "<!DOCTYPE cross-domain-policy SEM \"/xml/dtds/cross-domain-policy.dtd\">"
    "<cross-domain-policy><site-control permitted-cross-domain-policies=\"all\"/>"
    "<allow-access-from domain=\"*\" to-ports=\"*\" />"
    "</cross-domain-policy>";

get_response(T = #tag{name=connect}) ->
    Username = proplists:get_value(username, T#tag.attributes),
    lists:concat(["<loggedOn username=\"", Username, "\" userid=\"1\"/>"]);


get_response(#tag{name=chat, attributes=[{chatMessage, "debug> erlbus"}]}) ->
    %TODO: implement for real
    ebus:pub("lobby", {rxbroadcast, "<chat chatMessage=\"broadcast msg\"/>"}),
    "<chat chatMessage=\"debug erlbus\"/>";

get_response(#tag{name=chat, attributes=[{chatMessage, "debug> addUser"}]}) ->
    %TODO: implement for real
  lists:concat(["<addUser username=\"mrwhite\" avatar=\"1|GB\" userid=\"2\"/>"]);


get_response(#tag{name=chat, attributes=[{chatMessage, "debug> rxChallenge"}]}) ->
    %TODO: implement for real
    "<invite message=\"0\" gameTypeId=\"\" userid=\"2\" targetUserId=\"1\" username=\"mrwhite\" avatar=\"1\" />";

%get_response(T = #tag{name=chat, attributes=[{chatMessage, "rxRecording"}]}) ->
    %TODO: implement for real
%    "<recording playerNum="3"><action x="150" y="150 r="50" splash="0" force="50" xforce="50" yforce="50" fire="0" weapon="1" crc="" energy1="" energy2="" energy3=""/></recording>";

get_response(#tag{name=chat, attributes=[{chatMessage, "debug> addMrWhiteToService"}]}) ->
    lists:concat(["<addedToService username=\"", "mrwhite", "\" userid=\"", "2" ,"\"/>"]);

get_response(#tag{name=sound}) ->
    %just for fun, should not be the response for any sound tag
    "<sound chatMessage=\"jibjab\" />";

get_response(T = #tag{name=selection}) ->
    TerrainChoice = proplists:get_value(terrainChoice, T#tag.attributes),
    lists:concat(["<selection terrainChoice=\"", TerrainChoice, "\"/>"]);


get_response(T = #tag{name=accept}) ->
    AcceptUserId = proplists:get_value(userid, T#tag.attributes),
    AcceptUsername = proplists:get_value(username, T#tag.attributes),
    lists:concat(["<addedToService username=\"", AcceptUsername, "\" userid=\"", AcceptUserId ,"\"/>"]);

get_response(T = #tag{name=decline}) ->
    UserId = proplists:get_value(userid, T#tag.attributes),
    Username = proplists:get_value(username, T#tag.attributes),
    TargetUserId = proplists:get_value(targetUserId, T#tag.attributes),
    TargetUsername = proplists:get_value(targetUsername, T#tag.attributes),
    GameTypeId = proplists:get_value(gameTypeId, T#tag.attributes),
    Message = proplists:get_value(message, T#tag.attributes),
    lists:concat(["<decline username=\"", Username, "\" userid=\"", UserId ,"\" targetUsername=\"", TargetUsername, "\" targetUserId=\"", TargetUserId ,"\" gameTypeId=\"", GameTypeId ,"\" message=\"", Message ,"\" />"]);

get_response(#tag{name=invite}) ->
    %[{message,"0"},
    %{gameTypeId,[]},
    %{avatar,"7"},
    %{username,"spoof"},
    %{userid,[]},
    %{targetUserId,"2"}],
    %Message = proplists:get_value(chatMessage, T#tag.attributes),

    %lists:concat(["<chat chatMessage=\"debug invite sent\"/>"]);
    timer:sleep(2500),
    lists:concat(["<accept targetUserId=\"1\" userid=\"2\" username=\"mrwhite\" avatar=\"1|GB\" gameTypeId=\"\" message=\"Ok!\" />"]);

get_response(#tag{name=cancel}) ->
    %  [{message,"spoof withdrew their challenge"},
    %             {gameTypeId,[]},
    %             {username,"spoof"},
    %             {userid,[]},
    %             {targetUserId,"2"}],
     "<chat chatMessage=\"debug invite cancelled\"/>";

%get_response(T = #tag{name=exitToLobby}) ->

get_response(T = #tag{name=chat}) ->
    Message = proplists:get_value(chatMessage, T#tag.attributes),
    lists:concat(["<chat chatMessage=\"", Message, "\"/>"]).

%get_response_test() ->
%    'chat tag' = get_response(get_tag("<chat/>\0"))
%    .
%get_tag_test() ->
%    {'policy-file-request', [], []} = get_tag("<policy-file-request/>\0")
%    .

pid_tokens(Pid) ->
    PidStr = pid_to_list(Pid),
    PidStr1 = lists:sublist(PidStr, 2, length(PidStr)-2),
    [N, P1, P2] = [list_to_integer(T) || T <- string:tokens(PidStr1,[$.])],
    {N, P1, P2}.


add_user(Username, Avatar, ID) ->
  lists:concat(["<addUser username=\"", Username, "\" avatar=\"", Avatar, "\" userid=\"", ID, "\"/>"]).

disconnect_user(ID) ->
  lists:concat(["<disconnectUser userId=\"", ID, "\"/>"]).

logged_on(Username, ID) ->
    lists:concat(["<loggedOn username=\"", Username, "\" userid=\"", ID, "\"/>"]).
