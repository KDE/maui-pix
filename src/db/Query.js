var Query = {

    allPics : "select * from images order by strftime(\"%s\", addDate) desc",
    picLikeUrl_ : "select * from images where url like \"%1%\" ",

    picTags_ : "select * from images_tags where url = \"%1\"",
    allTags : "select * from tags",

    allAlbums : "select * from albums order by strftime(\"%s\", addDate) desc",
    albumPics_ : "select i.* from images_albums ia inner join images i on i.url = ia.url where ia.album = \"%1\" order by strftime(\"%s\", ia.addDate) desc",

    favPics: "select * from images where fav = 1",
    recentPics: "select * from images order by strftime(\"%s\", addDate) desc limit 50"


}
