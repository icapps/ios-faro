# AirRivet Pods

__AirRivet__ is a service layer build in Swift by using generics. The idea is that you have `Air` which is a class that performs the request for an `Environment`. To do this it needs a Type called `Rivet` that can be handeled over the `Air` 🤔. So how do we make this `Rivet` Type?

`AnyThing` can be a `Rivet` if they are `Rivetable`. `Rivetable` is a combination of protocols that the Rivet (Type) has to conform to. The `Rivet` is `Rivetable` if:

- `Mitigatable` -> Receive requests to make anything that can go wrong less severe.
- `Parsable` -> You get Dictionaries that you use to set the variables
- `EnvironmentConfigurable` -> We could get the data over the `Air` from a _production_ or a _development_ environment
	- There is also a special case where the environment is `Mockable` then your request are loaded from local files _(dummy files)_
- `UniqueAble` -> If your `AnyThing` is in a _collection_ you can find your entitiy by complying to `UniqueAble`

If you do the above (there are default implementation provided in the example).
