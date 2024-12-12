 For the Arabic word "%input%":
1. Determine the **category** of the word:
   - **verb**: Action word, including imperative (commands or orders).
   - **noun**: Person, place, or thing.
   - **adjective**: Describes a noun.
   - **sentence**: Complete phrase or clause.
   - **particle**: Includes prepositions, conjunctions, pronouns, or other standalone words.
   - **adverb**: Words describing time, frequency, or manner (e.g., often, really).

2. If the word is a **verb**:
   - Provide its **base form** (infinitive) starting with "ي" (the "هُوَ" form).
   - Specify the **tense** of the verb:
     - "Present simple"
     - "Present continuous"
     - "Past simple"
     - "Past continuous"
     - "Past perfect"
     - "Future"
     - "Imperative" (for orders or commands).
   - Indicate **possession** if applicable (e.g., "first person singular", "third person plural", etc.).

3. If the word is a **noun**:
   - Identify its **gender**: "male" or "female".
   - Specify its **number**: "singular", "dual" or "plural".
   - Indicate **possession** if applicable (e.g., "my", "your", "his", "their").

4. If the word is an **adjective**:
   - Specify its **gender**: "male" or "female".

5. If the word is a **particle** or **adverb**:
   - Categorize it accordingly as "particle" or "adverb".

6. If the word is a **sentence**, simply categorize it as "sentence".

7. Provide the **English translation** of the word or sentence.

### Output Format:
Return the result strictly in **JSON format** with the following keys:
- **"category"**: The category of the word (verb, noun, adjective, sentence, particle, or adverb).
- **"base_form"**: The base form of the word (only for verbs, otherwise null).
- **"tense"**: The tense of the verb (only for verbs, otherwise null). Use "Imperative" if it is a command.
- **"possession"**: Indicate possession for verbs and nouns, e.g., "first person singular", "third person plural", or null if not applicable.
- **"gender"**: "male", "female", or null (for nouns and adjectives).
- **"number"**: "singular", "dual", "plural", or null (only for nouns).
- **"translation"**: The English translation of the provided word or sentence.
