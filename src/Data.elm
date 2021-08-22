module Data exposing
    ( DataDict
    , DataFile
    , DataId
    , Datum
    , deletedSnippetDocument
    , filter
    , fixUrls
    , insertDatum
    , make
    , remove
    , setupUser
    , signInDocument
    , signOutDocument
    , system
    , welcomeDocument
    )

import Dict exposing (Dict)
import Search exposing (SearchConfig(..))
import Time


type alias Username =
    String


type alias DataId =
    String


type alias Datum =
    { id : String
    , title : String
    , username : Username
    , content : String
    , tags : List String
    , creationData : Time.Posix
    , modificationData : Time.Posix
    }


system : Time.Posix -> String -> String -> String -> Datum
system currentTime id title content =
    { id = id
    , title = title
    , username = "system"
    , content = fixUrls content
    , tags = []
    , creationData = currentTime
    , modificationData = currentTime
    }


signOutDocument =
    system (Time.millisToPosix 0) "0" "Info" signOutText


deletedSnippetDocument =
    system (Time.millisToPosix 0) "1" "Info" deletedSnippetText


signInDocument =
    system (Time.millisToPosix 0) "2" "Info" signInText


welcomeDocument =
    system (Time.millisToPosix 0) "3" "Info" welcomeText


welcomeText =
    """
- **To Sign Up:** Enter a username with at least four letters or numbers beginning with a letter, then enter a password.

- **To edit a snippet:** click the left (slate gray) button.

- **To view a snippet:** click the right (pink) button.

### Searching for snippets

Put words or fragments of words in the search box separated by a space.  For example 'atom smasher' will find
all snippets containing 'atom' and 'smasher'.  Searching for 'ato sma' will do the same.  Searching for
'atom -smash' will find all snippets contaning 'atom' but not 'smash'.

### Sorting snippets

- **A** sorts snippets alphabetically.

- **D** sorts snippets by the date-time of last modification.

- **R** sorts snippets randomly

### Markdown

You can use markdown and also LaTeX-style math formulas: $a^2 + b^2 = c^2$ and

$$
\\int_0^1 x^n dx = \\frac{1}{n+1}
$$



### Expofg

- The **Export** button will export all of your snippets to a `.yaml` file.
"""


deletedSnippetText =
    """
Snippet deleted
"""


signInText =
    """
Please sign in or sign up
"""


signOutText =
    """
You are signed out.
"""


make : Username -> Time.Posix -> String -> String -> Datum
make username currentTime id content =
    { id = id
    , title = content |> String.lines |> List.head |> Maybe.withDefault "TITLE"
    , username = username
    , content = fixUrls content
    , tags = []
    , creationData = currentTime
    , modificationData = currentTime
    }


type alias DataFile =
    { data : List Datum
    , username : Username
    , creationData : Time.Posix
    , modificationData : Time.Posix
    }


type alias DataDict =
    Dict Username DataFile


transformer { title, content, creationData } =
    { targetContent = title ++ String.replace "!!" "wow!" content, targetDate = creationData }


filter : String -> List Datum -> List Datum
filter filterString data =
    Search.search transformer NotCaseSensitive filterString data


filter1 : String -> List Datum -> List Datum
filter1 filterString data =
    let
        filterString_ =
            String.toLower filterString |> String.replace ":star" (String.fromChar '★')
    in
    List.filter (\datum -> String.contains filterString_ (String.toLower datum.content)) data


setupUser : Time.Posix -> Username -> DataDict -> DataDict
setupUser currentTime username dataDict =
    let
        newDataFile =
            { data = []
            , username = username
            , creationData = currentTime
            , modificationData = currentTime
            }
    in
    Dict.insert username newDataFile dataDict


insertDatum : Username -> Datum -> DataDict -> DataDict
insertDatum username datum dataDict =
    case Dict.get username dataDict of
        Nothing ->
            dataDict

        Just dataFile ->
            Dict.insert username { dataFile | data = datum :: dataFile.data } dataDict


remove : Username -> DataId -> DataDict -> DataDict
remove username id dataDict =
    case Dict.get username dataDict of
        Nothing ->
            dataDict

        Just dataFile ->
            let
                newData =
                    List.filter (\datum -> datum.id /= id) dataFile.data

                newDataFile =
                    { dataFile | data = newData }
            in
            Dict.insert username newDataFile dataDict


getUrls : String -> List String
getUrls str =
    str |> String.words |> List.filter isUrl


getLinkLabel : String -> String
getLinkLabel str =
    if String.left 7 str == "http://" then
        String.replace "http://" "" str

    else
        String.replace "https://" "" str


fixUrl : String -> String -> String
fixUrl url str =
    let
        label =
            getLinkLabel url

        link =
            " [" ++ label ++ "](" ++ url ++ ")"
    in
    String.replace url link str


fixUrls : String -> String
fixUrls str =
    let
        urls =
            getUrls str

        fixers =
            List.map fixUrl urls
    in
    List.foldl (\fixer str_ -> fixer str_) str fixers


isUrl : String -> Bool
isUrl str =
    String.left 4 str == "http"
