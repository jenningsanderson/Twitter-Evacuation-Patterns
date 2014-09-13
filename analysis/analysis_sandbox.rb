users = ["dogukanbiyik","kimdelcarmen","rchieB","fernanjos","nicolelmancini","Krazysoto","alishbot","CharisseCrammer","jericajazz","KD804","jesssgilligan","theJKinz","TheAwesomeMom","bjacksrevenge","jefflac","roobs83","jds2001","SimoMarms","NYCGreenmarkets","MoazaMatar","c3nki","KiiddPhenom","sandelestepan","tlal2","BeachyIsPeachy","cyantifik","FrankKnuck","mattgunn","Max_Not_Mark","JaclynPatrice","Rigo7x","ajc6789","yagoSMASH","polinchock","indavewetrust","CillaCindaplc2B","Javy_Jaz","eric13000","becaubs","enriqueskincare","Rivkind","janelles__world","CoreyKelly","josalazas","CapponiWho","JohnBakalian1","valcristdk","forero29","BobGrotz","CodyRodrigu3z","CoastalArtists","VSindha"]






users.each do |user|

	print %Q{#### #{user}
```{r original_#{user}, echo=FALSE, warning=FALSE, fig.width=16, fig.height=8}
data = read.csv("../exports_3/#{user}_norm_distances.csv")
get_ggplot(data)
```

}

end
