import System.Random
import System.Environment

-- Pizzas: a name, priority and price
type Pizza = (String, Int, Double)

maxprice = 1200

pizzas :: [Pizza]
pizzas = [ ("Pappas spesial",                                            4, 159)
         , ("Texas",                                                     3, 149)
         , ("Blue Hawai",                                                7, 149)
         , ("Floriad",                                                   4, 149)
         , ("Buffalo",                                                   4, 149)
         , ("Chicken",                                                   4, 149)
         , ("New York",                                                  0, 149)
         , ("Las Vegas",                                                 6, 149)
         , ("Vegetarianer",                                              0, 149)
         , ("FILADELFIA",                                                4, 149)
         , ("Hot Chicago",                                               7, 149)
         , ("Hot Express",                                               5, 149)
         , ("Kebab pizza spesial",                                       3, 169)
         , ("Egenkomponert, Pepperoni, Biff, Bacon, Skinke, løk",        9, 159)
         , ("Egenkomponert, Biff, Pepperoni, Bacon, Skinke, Tacokjøtt",  9, 159)
           ]

reprice :: Double -> [Pizza] -> [Pizza]
reprice new_price = map (\(s,n,_) -> (s,n,new_price))

prioritize :: [Pizza] -> [Pizza]
prioritize [] = []
prioritize   ((s, 0, pr):xs) = prioritize xs
prioritize (p@(s, n, pr):xs) = p : prioritize ( (s, n-1, pr) : xs )

-- Get N random pizzas
randomN :: StdGen -> Int -> [a] -> [a]
randomN rand n xs = rn rand n (length xs) xs
    where rn _ _ _ [] = []
          rn rand n m (x:xs) = let (r, gen) = randomR (1,m) rand
                               in  if r <= n
                                   then x : rn gen (n-1) (m-1) xs
                                   else     rn gen n (m-1) xs

choosePizzas :: StdGen -> Int -> Bool -> [Pizza]
choosePizzas random eaters cheap = 
    let ps = if cheap
             then prioritize (reprice 119 pizzas)
             else prioritize pizzas
        number = round $ (fromIntegral eaters * 0.4) + 0.5
    in randomN random number ps

takePizzas :: Double -> Double -> [Pizza] -> [(String,Double)]
takePizzas cur _ [] = [("Totalt: ", cur)]
takePizzas cur max ((s,n,pr):ps)
    | cur+pr > max = takePizzas cur max []
    | otherwise = (s,pr) : takePizzas (cur+pr) max ps

prettyprint :: Show a => [(String, a)] -> IO ()
prettyprint = mapM_ pp
    where pp ("Totalt: ", price) = putStrLn $ "----------\nTotalt:\t\t" ++ show price
          pp (name, price)       = putStrLn $ name ++ "\t\t" ++ show price

main = do args <- getArgs
          random <- newStdGen
          let eaters = read (args !! 0)
              cheap  = if length args > 1
                       then True
                       else False
          putStrLn $ "Pizza eaters: " ++ show eaters
          prettyprint . takePizzas 0 maxprice $ choosePizzas random eaters cheap
