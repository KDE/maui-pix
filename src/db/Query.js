var Query = {

    allPics : "select * from images order by strftime(\"%s\", addDate) desc",
    picLikeUrl_ : "select * from images where url like \"%1%\" ",

    picTags_ : "select * from images_tags where url = \"%1\"",
    allTags : "select * from tags"
}
