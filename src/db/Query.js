var Query = {

    allPics : "select * from images order by strftime(\"%s\", addDate) desc",
    picLikeUrl_ : "select * from images where url like \"%1%\" order by strftime(\"%s\", addDate) desc",
    picUrl_ : "select * from images where url = \"%1\"",

    albumTags_ : "select * from albums_tags where album = \"%1\"",
    picTags_ : "select * from images_tags where url = \"%1\"",
    allTags : "select * from tags",
    tagPics_: "select i.* from images i inner join images_tags it on it.url = i.url where it.tag = \"%1\"",

    allAlbums : "select * from albums",
    allAlbumPics_ : "select distinct i.* from images i inner join images_tags it on it.url = i.url inner join albums_tags at on at.tag = it.tag where at.album = \"%1\" union select i.* from images_albums ia inner join images i on i.url = ia.url where ia.album = \"%1\"",
    albumPics_ : "select i.* from images_albums ia inner join images i on i.url = ia.url where ia.album = \"%1\" order by strftime(\"%s\", ia.addDate) desc",
    albumPicsTags_ : "select i.* from images i  inner join images_tags it on it.url = i.url inner join albums_tags at on at.tag = it.tag where at.album = \"%1\"",
    favPics: "select * from images where fav = 1",
    recentPics: "select * from images order by strftime(\"%s\", addDate) desc limit 50",

    folders_: "select distinct s.url from images i inner join sources s on s.url = i.source where i.url like \"%%1%\" or i.title like \"%%1%\"",

    searchFor_: "select * from images where title like \"%%1%\" or url like \"%%1%\" union select distinct i.* from images i inner join images_tags it on it.url = i.url where it.tag like \"%%1%\" collate nocase limit 1000"
}
