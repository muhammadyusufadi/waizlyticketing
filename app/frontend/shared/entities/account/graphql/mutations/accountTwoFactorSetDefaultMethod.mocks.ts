import * as Types from '#shared/graphql/types.ts';

import * as Mocks from '#tests/graphql/builders/mocks.ts'
import * as Operations from './accountTwoFactorSetDefaultMethod.api.ts'

export function mockAccountTwoFactorSetDefaultMethodMutation(defaults: Mocks.MockDefaultsValue<Types.AccountTwoFactorSetDefaultMethodMutation, Types.AccountTwoFactorSetDefaultMethodMutationVariables>) {
  return Mocks.mockGraphQLResult(Operations.AccountTwoFactorSetDefaultMethodDocument, defaults)
}

export function waitForAccountTwoFactorSetDefaultMethodMutationCalls() {
  return Mocks.waitForGraphQLMockCalls<Types.AccountTwoFactorSetDefaultMethodMutation>(Operations.AccountTwoFactorSetDefaultMethodDocument)
}
