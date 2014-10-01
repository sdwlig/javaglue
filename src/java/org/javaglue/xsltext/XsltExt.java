package org.javaglue.xsltext;

/**
 * 
 * This class provides methods to be used in XSLT.
 * 
 * 
 * @author Christoph Nenning
 */
public class XsltExt {

    /**
     * 
     * Counts how many times a character occurs in a string.
     * Needed to find out the type parameters of a template.
     * Consider following case:
     * <code>
     * std::map &lt; std::pair&lt; std::vector&lt; std::string &gt;, std::string &gt;, std::pair&lt; std::string, std::vector&lt; std::string &gt; &gt; &gt;
     * </code>
     * 
     * @param str String in which shall be searched.
     * @param character Character to search for.
     * @return How many times character occurs in str.
     */
    public static int countOccurrencesInString(String str, String character) {
        int result = 0;
        for(int i=0; i<str.length(); i++) {
            if (str.charAt(i) == character.charAt(0)) result++;
        }
        return result;
    }
}
