var Query = {

    allPics : "select * from images order by strftime(\"%s\", addDate) desc",
    picLikeUrl_ : "select * from images where url like \"%1%\" order by strftime(\"%s\", addDate) desc",
    picUrl_ : "select * from images where url = \"%1\"",

    recentPics: "select * from images order by strftime(\"%s\", addDate) desc limit 50",

    folders_: "select distinct s.url from images i inner join sources s on s.url = i.source where i.url like \"%%1%\" or i.title like \"%%1%\"",

    searchFor_: "select * from images where title like \"%%1%\" or url like \"%%1%\" collate nocase limit 1000"
}
