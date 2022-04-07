
function makeIndex() {
    function makeLink(id,item,index) {
        var link = document.createElement("a");
        $(link).text(item);
        $(link).attr("href","#"+id+index)
        var li = document.createElement("li");
        $(li).append(link)
        return li
    }
    
    var count = 0
    var titles = new Array();
    var subtitles = new Array();
    $("article").each(function() {
        var subTitleArr = new Array();
        var scount = 0
        $(this).attr("id","article"+count);
        var h2 = $(this).find("h2")
        h2.attr("id","h2"+count);
        if ($(h2).text() != "") {
            titles.push($(h2).text());
        }
        $(this).find("h3").each(function() {
            $(this).attr("id","h3"+count+"_"+scount);
            scount += 1
            subTitleArr.push($(this).text());
        });
        subtitles.push(subTitleArr);
        count += 1;
    });
    
    if (titles.length > 0) {
        var nav = document.createElement("nav")
        $(nav).attr("id","navi")
        $("article:first-of-type").before(nav);
        var ul = document.createElement("ol")
        $(nav).append(ul);
    }
    
    for (var i = 0 ; i < titles.length ; i ++) {
        var item = makeLink("h2",titles[i],i);
        var ulid = "ol_"+i
        $(item).attr("id",ulid)
        $("#navi > ol").append(item);
        
        if (subtitles[i].length > 0) {
            var ul = document.createElement("ol");
            
            for (var j = 0; j < subtitles[i].length; j ++) {
                var item = makeLink("h3",subtitles[i][j],i+"_"+j)
                $(ul).append(item);
            }
            $("#"+ulid).append(ul);
        }
    }
    
    if (titles.length > 0) {
        var naviLink = document.createElement("a");
        $(naviLink).attr("href","#navi");
        $(naviLink).text("#toTop");
        $(naviLink).attr("class","toTop");
        $("h2,h3").append(naviLink);
    }
}

$(document).ready(function(){
    makeIndex();
})

function changeMode(name) {
    $("body").attr("class",name)
}
